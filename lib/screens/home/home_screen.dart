import 'package:flutter/material.dart';
import '../../models/content_item.dart';
import '../../models/enums.dart';
import '../../models/profile_type.dart';
import '../../services/database_service.dart';
import '../../widgets/content_card.dart';
import '../../widgets/profile_switcher.dart';
import '../../widgets/profile_stats_card.dart';

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
        title: Row(
          children: [
            const Text(
              'Home',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 12),
            _buildProfileSelector(),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTypeDropdown(),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildCategoryFilter(),
          ProfileStatsCard(selectedProfile: widget.selectedProfile),
          Expanded(child: _buildContentList()),
        ],
      ),
    );
  }

  Widget _buildProfileSelector() {
    return GestureDetector(
      onTap: () async {
        if (widget.selectedProfile != null) {
          final newProfile = await ProfileSwitcher.show(
            context,
            widget.selectedProfile!,
          );
          if (newProfile != null) {
            widget.onProfileChange(newProfile);
            // Reset filters when profile changes
            setState(() {
              _selectedType = null;
              _selectedCategory = null;
            });
          }
        }
      },
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: widget.selectedProfile?.color.withOpacity(0.1) ?? Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.selectedProfile?.color ?? Colors.grey,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.selectedProfile?.icon ?? Icons.apps,
              size: 16,
              color: widget.selectedProfile?.color ?? Colors.grey,
            ),
            const SizedBox(width: 4),
            Text(
              widget.selectedProfile?.displayName ?? 'All',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: widget.selectedProfile?.color ?? Colors.grey,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: widget.selectedProfile?.color ?? Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeDropdown() {
    return DropdownButton<ContentType?>(
      value: _selectedType,
      isExpanded: true,
      underline: Container(),
      hint: const Text('All Types'),
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
                // Switch to Discover tab (index 1)
                DefaultTabController.of(context).animateTo(1);
              },
              icon: const Icon(Icons.explore),
              label: const Text('Discover Content'),
            ),
          ],
        ),
      ),
    );
  }
}
