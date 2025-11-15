import 'package:flutter/material.dart';
import '../../models/content_item.dart';
import '../../models/enums.dart';
import '../../models/profile_type.dart';
import '../../services/database_service.dart';
import '../../widgets/content_card.dart';
import '../../widgets/profile_switcher.dart';

/// Home screen - Shows currently watching content
class HomeScreen extends StatefulWidget {
  final ProfileType? selectedProfile;
  final Function(ProfileType) onProfileChange;

  const HomeScreen({
    super.key,
    this.selectedProfile,
    required this.onProfileChange,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _db = DatabaseService();
  ContentType? _selectedType;
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _buildTypeDropdown(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCategoryFilter(),
          Expanded(child: _buildContentList()),
        ],
      ),
    );
  }

  Widget _buildTypeDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButton<ContentType?>(
        value: _selectedType,
        underline: Container(),
        hint: const Text('Filter'),
        icon: const Icon(Icons.filter_list, size: 18),
        items: [
          const DropdownMenuItem<ContentType?>(
            value: null,
            child: Text('All Types'),
          ),
          const DropdownMenuItem<ContentType?>(
            value: ContentType.anime,
            child: Text('Anime'),
          ),
          const DropdownMenuItem<ContentType?>(
            value: ContentType.comic,
            child: Text('Comics'),
          ),
          const DropdownMenuItem<ContentType?>(
            value: ContentType.novel,
            child: Text('Novels'),
          ),
          const DropdownMenuItem<ContentType?>(
            value: ContentType.movie,
            child: Text('Movies'),
          ),
          const DropdownMenuItem<ContentType?>(
            value: ContentType.tvSeries,
            child: Text('TV Series'),
          ),
        ],
        onChanged: (value) {
          setState(() {
            _selectedType = value;
            _selectedCategory = null; // Reset category when type changes
          });
        },
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return FutureBuilder<List<ContentItem>>(
      future: _fetchBaseContent(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final categories = snapshot.data!
            .where((item) => item.category != null && item.category!.isNotEmpty)
            .map((item) => item.category!)
            .toSet()
            .toList()
          ..sort();

        if (categories.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _selectedCategory == null,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = null;
                    });
                  },
                  selectedColor: widget.selectedProfile?.color.withOpacity(0.2),
                ),
                const SizedBox(width: 8),
                ...categories.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category),
                      selected: _selectedCategory == category,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = selected ? category : null;
                        });
                      },
                      selectedColor: widget.selectedProfile?.color.withOpacity(0.2),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<List<ContentItem>> _fetchBaseContent() async {
    // Get base content without category filter
    if (_selectedType != null) {
      return await _db.getContentItemsByTypeAndStatus(
        _selectedType!,
        ContentStatus.watching,
      );
    } else if (widget.selectedProfile != null) {
      return await _db.getContentItemsByTypeAndStatus(
        widget.selectedProfile!.contentType,
        ContentStatus.watching,
      );
    } else {
      return await _db.getContentItemsByStatus(ContentStatus.watching);
    }
  }

  Future<List<ContentItem>> _fetchContent() async {
    List<ContentItem> items = await _fetchBaseContent();

    // Apply category filter if selected
    if (_selectedCategory != null) {
      items = items.where((item) => item.category == _selectedCategory).toList();
    }

    return items;
  }

  Widget _buildContentList() {
    return FutureBuilder<List<ContentItem>>(
      future: _fetchContent(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading content',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final items = snapshot.data ?? [];

        if (items.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ContentCard(
                item: item,
                onChanged: () => setState(() {}),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_circle_outline,
              size: 100,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Nothing Playing',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Content you\'re actively enjoying will appear here',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                // Switch to Library tab (index 3)
                DefaultTabController.of(context).animateTo(3);
              },
              icon: const Icon(Icons.library_books),
              label: const Text('Go to Library'),
            ),
          ],
        ),
      ),
    );
  }
}
