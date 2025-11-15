import 'package:flutter/material.dart';
import '../models/content_item.dart';
import '../models/enums.dart';
import '../models/profile_type.dart';
import '../services/database_service.dart';

/// Stats card showing quick statistics for the selected profile
class ProfileStatsCard extends StatelessWidget {
  final ProfileType? selectedProfile;

  const ProfileStatsCard({
    super.key,
    this.selectedProfile,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: _fetchStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            margin: EdgeInsets.all(16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError) {
          return const SizedBox.shrink();
        }

        final stats = snapshot.data ?? {};
        final total = stats['total'] ?? 0;
        final watching = stats['watching'] ?? 0;
        final completed = stats['completed'] ?? 0;
        final planToWatch = stats['planToWatch'] ?? 0;

        // Don't show card if no content
        if (total == 0) {
          return const SizedBox.shrink();
        }

        return Card(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          elevation: 2,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  selectedProfile?.color.withOpacity(0.1) ?? Colors.grey.withOpacity(0.1),
                  selectedProfile?.color.withOpacity(0.05) ?? Colors.grey.withOpacity(0.05),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        selectedProfile?.icon ?? Icons.apps,
                        color: selectedProfile?.color ?? Colors.grey,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${selectedProfile?.displayName ?? 'All'} Stats',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: selectedProfile?.color ?? Colors.grey,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        context,
                        'Total',
                        total,
                        Icons.library_books,
                        selectedProfile?.color ?? Colors.grey,
                      ),
                      _buildStatItem(
                        context,
                        'Watching',
                        watching,
                        Icons.play_circle_outline,
                        Colors.blue,
                      ),
                      _buildStatItem(
                        context,
                        'Completed',
                        completed,
                        Icons.check_circle_outline,
                        Colors.green,
                      ),
                      _buildStatItem(
                        context,
                        'Planned',
                        planToWatch,
                        Icons.bookmark_outline,
                        Colors.orange,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    int value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 28,
        ),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
        ),
      ],
    );
  }

  Future<Map<String, int>> _fetchStats() async {
    final db = DatabaseService();

    List<ContentItem> allItems;
    List<ContentItem> watchingItems;
    List<ContentItem> completedItems;
    List<ContentItem> planToWatchItems;

    if (selectedProfile != null) {
      final type = selectedProfile!.contentType;
      allItems = await db.getContentItemsByType(type);
      watchingItems = await db.getContentItemsByTypeAndStatus(type, ContentStatus.watching);
      completedItems = await db.getContentItemsByTypeAndStatus(type, ContentStatus.completed);
      planToWatchItems = await db.getContentItemsByTypeAndStatus(type, ContentStatus.planToWatch);
    } else {
      allItems = await db.getAllContentItems();
      watchingItems = await db.getContentItemsByStatus(ContentStatus.watching);
      completedItems = await db.getContentItemsByStatus(ContentStatus.completed);
      planToWatchItems = await db.getContentItemsByStatus(ContentStatus.planToWatch);
    }

    return {
      'total': allItems.length,
      'watching': watchingItems.length,
      'completed': completedItems.length,
      'planToWatch': planToWatchItems.length,
    };
  }
}
