import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shimmer/shimmer.dart';
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Home', style: theme.appBarTheme.titleTextStyle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _buildProfileSelector(),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type filter
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: _buildTypeDropdown(),
          ),
          // Category filter
          _buildCategoryFilter(),
          // Content list
          Expanded(child: _buildContentList()),
        ],
      ),
    );
  }

  Widget _buildProfileSelector() {
    final colorScheme = Theme.of(context).colorScheme;

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
              _selectedCategory = null;
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

  Widget _buildTypeDropdown() {
    final theme = Theme.of(context);

    return SingleChildScrollView(
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
          _selectedCategory = null;
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
          return _buildShimmerLoading(context);
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
              PhosphorIconsRegular.playCircle,
              size: 100,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ).animate()
              .fadeIn(duration: 600.ms)
              .scale(delay: 200.ms, duration: 400.ms),
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
              icon: Icon(PhosphorIconsRegular.compass),
              label: const Text('Discover Content'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final baseColor = colorScheme.surfaceContainerHighest;
    final highlightColor = colorScheme.surfaceContainerLow;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thumbnail skeleton
                    Container(
                      width: 80,
                      height: 112,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Content skeleton
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Container(
                            height: 20,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 20,
                            width: 180,
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Chips
                          Row(
                            children: [
                              Container(
                                height: 28,
                                width: 70,
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                height: 28,
                                width: 90,
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Progress bar
                          Container(
                            height: 4,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
