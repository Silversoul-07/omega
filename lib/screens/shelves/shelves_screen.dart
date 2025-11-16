import 'package:flutter/material.dart';
import '../../models/content_item.dart';
import '../../models/enums.dart';
import '../../models/profile_type.dart';
import '../../services/database_service.dart';
import '../../widgets/content_grid_card.dart';
import '../../widgets/add_content_fab.dart';
import '../../widgets/profile_selector_button.dart';

/// Shelves screen - Status-based organization
/// Shows content filtered by status: Planned, Completed, On Hold, Dropped
class ShelvesScreen extends StatefulWidget {
  final ProfileType? selectedProfile;
  final Function(ProfileType) onProfileChange;

  const ShelvesScreen({
    super.key,
    this.selectedProfile,
    required this.onProfileChange,
  });

  @override
  State<ShelvesScreen> createState() => _ShelvesScreenState();
}

class _ShelvesScreenState extends State<ShelvesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _db = DatabaseService();
  int _refreshKey = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Shelves',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (widget.selectedProfile != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ProfileSelectorButton(
                selectedProfile: widget.selectedProfile,
                onProfileChange: widget.onProfileChange,
                onChanged: () => setState(() => _refreshKey++),
              ),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Planned'),
            Tab(text: 'Completed'),
            Tab(text: 'On Hold'),
            Tab(text: 'Dropped'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStatusTab(ContentStatus.planToWatch),
          _buildStatusTab(ContentStatus.completed),
          _buildStatusTab(ContentStatus.onHold),
          _buildStatusTab(ContentStatus.dropped),
        ],
      ),
      floatingActionButton: AddContentFAB(
        heroTag: 'shelves_fab',
        selectedProfile: widget.selectedProfile,
        onContentAdded: () => setState(() => _refreshKey++),
      ),
    );
  }

  Widget _buildStatusTab(ContentStatus status) {
    return FutureBuilder<List<ContentItem>>(
      key: ValueKey('status_${status.name}_$_refreshKey'),
      future: _fetchContentByStatus(status),
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
          return _buildEmptyState(status);
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

  Future<List<ContentItem>> _fetchContentByStatus(ContentStatus status) async {
    List<ContentItem> items;

    if (widget.selectedProfile == null) {
      items = await _db.getContentItemsByStatus(status);
    } else {
      items = await _db.getContentItemsByTypeAndStatus(
        widget.selectedProfile!.contentType,
        status,
      );
    }

    // Sort by most recently updated
    items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return items;
  }

  Widget _buildEmptyState(ContentStatus status) {
    final messages = _getEmptyStateMessages(status);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              messages['icon'] as IconData,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              messages['title'] as String,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              messages['subtitle'] as String,
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

  Map<String, dynamic> _getEmptyStateMessages(ContentStatus status) {
    switch (status) {
      case ContentStatus.planToWatch:
        return {
          'icon': Icons.bookmark_outline,
          'title': 'No Planned Content',
          'subtitle': 'Tap + to add something to watch later!',
        };
      case ContentStatus.completed:
        return {
          'icon': Icons.check_circle_outline,
          'title': 'Nothing Completed Yet',
          'subtitle': 'Keep watching! Completed content will appear here.',
        };
      case ContentStatus.onHold:
        return {
          'icon': Icons.pause_circle_outline,
          'title': 'No Content On Hold',
          'subtitle': 'Content you\'ve paused will appear here.',
        };
      case ContentStatus.dropped:
        return {
          'icon': Icons.cancel_outlined,
          'title': 'No Dropped Content',
          'subtitle': 'Content you\'ve dropped will appear here.',
        };
      case ContentStatus.watching:
        return {
          'icon': Icons.play_circle_outline,
          'title': 'Not Watching Anything',
          'subtitle': 'Start watching something!',
        };
    }
  }
}
