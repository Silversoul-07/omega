import 'package:flutter/material.dart';
import '../../models/content_item.dart';
import '../../models/enums.dart';
import '../../models/profile_type.dart';
import '../../services/database_service.dart';
import '../../widgets/content_grid_card.dart';
import '../../widgets/profile_switcher.dart';

/// Library screen - View all content in library
class LibraryScreen extends StatefulWidget {
  final ProfileType? selectedProfile;
  final Function(ProfileType) onProfileChange;

  const LibraryScreen({
    super.key,
    this.selectedProfile,
    required this.onProfileChange,
  });

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _db = DatabaseService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildProfileBadge() {
    return GestureDetector(
      onTap: () async {
        if (widget.selectedProfile != null) {
          final newProfile = await ProfileSwitcher.show(
            context,
            widget.selectedProfile!,
          );
          if (newProfile != null) {
            widget.onProfileChange(newProfile);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text(
              'Library',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 12),
            _buildProfileBadge(),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Completed'),
            Tab(text: 'Plan to Watch'),
            Tab(text: 'On Hold'),
            Tab(text: 'Dropped'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllTab(),
          _buildStatusTab(ContentStatus.completed),
          _buildStatusTab(ContentStatus.planToWatch),
          _buildStatusTab(ContentStatus.onHold),
          _buildStatusTab(ContentStatus.dropped),
        ],
      ),
    );
  }

  Widget _buildAllTab() {
    return FutureBuilder<List<ContentItem>>(
      future: widget.selectedProfile == null
          ? _db.getAllContentItems()
          : _db.getContentItemsByType(widget.selectedProfile!.contentType),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final items = snapshot.data ?? [];

        if (items.isEmpty) {
          return _buildEmptyState(
            icon: Icons.library_books_outlined,
            title: 'No Content Yet',
            subtitle: 'Add some content from the Discover tab or use Settings to populate test data',
          );
        }

        return _buildContentList(items);
      },
    );
  }

  Widget _buildStatusTab(ContentStatus status) {
    return FutureBuilder<List<ContentItem>>(
      future: widget.selectedProfile == null
          ? _db.getContentItemsByStatus(status)
          : _db.getContentItemsByTypeAndStatus(
              widget.selectedProfile!.contentType, status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final items = snapshot.data ?? [];

        if (items.isEmpty) {
          return _buildEmptyState(
            icon: _getStatusIcon(status),
            title: 'No ${status.displayName} Content',
            subtitle: 'Content marked as "${status.displayName}" will appear here',
          );
        }

        return _buildContentList(items);
      },
    );
  }

  Widget _buildContentList(List<ContentItem> items) {
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
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
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

  IconData _getStatusIcon(ContentStatus status) {
    switch (status) {
      case ContentStatus.watching:
        return Icons.play_circle_outline;
      case ContentStatus.completed:
        return Icons.check_circle_outline;
      case ContentStatus.planToWatch:
        return Icons.bookmark_outline;
      case ContentStatus.onHold:
        return Icons.pause_circle_outline;
      case ContentStatus.dropped:
        return Icons.cancel_outlined;
    }
  }
}
