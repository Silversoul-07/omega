import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../models/content_item.dart';
import '../../models/enums.dart';
import '../../models/profile_type.dart';
import '../../services/database_service.dart';
import '../../widgets/content_grid_card.dart';
import '../../widgets/profile_switcher.dart';
import 'add_content_screen.dart';

/// Discover screen - Browse and search content
class DiscoverScreen extends StatefulWidget {
  final ProfileType? selectedProfile;
  final Function(ProfileType) onProfileChange;

  const DiscoverScreen({
    super.key,
    this.selectedProfile,
    required this.onProfileChange,
  });

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final _db = DatabaseService();
  final _searchController = TextEditingController();
  String _searchQuery = '';
  ContentType? _selectedType;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openAddContentScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddContentScreen(
          selectedProfile: widget.selectedProfile,
        ),
      ),
    );

    // Refresh if content was added
    if (result == true && mounted) {
      setState(() {});
    }
  }

  Widget _buildProfileBadge() {
    return FilledButton.tonalIcon(
      onPressed: () async {
        if (widget.selectedProfile != null) {
          final newProfile = await ProfileSwitcher.show(
            context,
            widget.selectedProfile!,
          );
          if (newProfile != null) {
            widget.onProfileChange(newProfile);
            setState(() {
              _selectedType = null;
            });
          }
        }
      },
      icon: Icon(
        widget.selectedProfile?.icon ?? PhosphorIconsRegular.squares,
        size: 18,
      ),
      label: Text(widget.selectedProfile?.displayName ?? 'All'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Discover', style: theme.appBarTheme.titleTextStyle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _buildProfileBadge(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          _buildSearchBar(),
          // Filter chips
          _buildFilterChips(),
          // Content grid
          Expanded(
            child: _buildContentList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddContentScreen(),
        icon: Icon(PhosphorIconsRegular.plus),
        label: const Text('Add'),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search content...',
          prefixIcon: Icon(PhosphorIconsRegular.magnifyingGlass),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(PhosphorIconsRegular.x),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          filled: true,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('All', null),
            const SizedBox(width: 8),
            _buildFilterChip('Anime', ContentType.anime),
            const SizedBox(width: 8),
            _buildFilterChip('Comics', ContentType.comic),
            const SizedBox(width: 8),
            _buildFilterChip('Novels', ContentType.novel),
            const SizedBox(width: 8),
            _buildFilterChip('Movies', ContentType.movie),
            const SizedBox(width: 8),
            _buildFilterChip('TV Series', ContentType.tvSeries),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, ContentType? type) {
    final isSelected = _selectedType == type;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedType = selected ? type : null;
        });
      },
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
    );
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
                  PhosphorIconsRegular.warningCircle,
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
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.55,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ContentGridCard(
                item: item,
                onChanged: () => setState(() {}),
              );
            },
          ),
        );
      },
    );
  }

  Future<List<ContentItem>> _fetchContent() async {
    List<ContentItem> items;

    // Apply filters: search > _selectedType > selectedProfile > all
    // Always filter to show only "Plan to Watch" items (unstarted content to discover)
    if (_searchQuery.isNotEmpty) {
      items = await _db.searchByTitle(_searchQuery);
      // Filter by profile and status
      items = items.where((item) {
        final matchesProfile = widget.selectedProfile == null ||
            item.type == widget.selectedProfile!.contentType;
        final isPlanToWatch = item.status == ContentStatus.planToWatch;
        return matchesProfile && isPlanToWatch;
      }).toList();
    } else if (_selectedType != null) {
      items = await _db.getContentItemsByTypeAndStatus(
        _selectedType!,
        ContentStatus.planToWatch,
      );
    } else if (widget.selectedProfile != null) {
      items = await _db.getContentItemsByTypeAndStatus(
        widget.selectedProfile!.contentType,
        ContentStatus.planToWatch,
      );
    } else {
      items = await _db.getContentItemsByStatus(ContentStatus.planToWatch);
    }

    return items;
  }

  Widget _buildEmptyState() {
    if (_searchQuery.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                PhosphorIconsRegular.magnifyingGlass,
                size: 80,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No Results Found',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try searching with different keywords',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIconsRegular.compass,
              size: 100,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Nothing to Discover',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Content marked as "Plan to Watch" will appear here for you to discover',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                // Switch to Settings tab (index 3)
                DefaultTabController.of(context).animateTo(3);
              },
              icon: Icon(PhosphorIconsRegular.gear),
              label: const Text('Populate Test Data'),
            ),
          ],
        ),
      ),
    );
  }
}
