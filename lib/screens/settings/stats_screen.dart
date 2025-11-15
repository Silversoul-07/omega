import 'package:flutter/material.dart';
import '../../models/content_item.dart';
import '../../models/enums.dart';
import '../../models/profile_type.dart';
import '../../services/database_service.dart';

/// Statistics screen showing detailed library analytics
class StatsScreen extends StatelessWidget {
  final ProfileType? selectedProfile;

  const StatsScreen({
    super.key,
    this.selectedProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Statistics',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchAllStats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                ],
              ),
            );
          }

          final stats = snapshot.data ?? {};

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Profile header
              _buildProfileHeader(context),
              const SizedBox(height: 24),

              // Overall stats
              _buildOverallStatsCard(context, stats),
              const SizedBox(height: 16),

              // Status breakdown
              _buildStatusBreakdownCard(context, stats),
              const SizedBox(height: 16),

              // Type breakdown (if no profile selected)
              if (selectedProfile == null) ...[
                _buildTypeBreakdownCard(context, stats),
                const SizedBox(height: 16),
              ],

              // Category breakdown
              _buildCategoryBreakdownCard(context, stats),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              selectedProfile?.color.withOpacity(0.15) ?? Colors.grey.withOpacity(0.1),
              selectedProfile?.color.withOpacity(0.05) ?? Colors.grey.withOpacity(0.05),
            ],
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: selectedProfile?.color.withOpacity(0.2) ?? Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                selectedProfile?.icon ?? Icons.analytics,
                size: 40,
                color: selectedProfile?.color ?? Colors.grey,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedProfile?.displayName ?? 'All Content',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: selectedProfile?.color ?? Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Library Statistics',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallStatsCard(BuildContext context, Map<String, dynamic> stats) {
    final total = stats['total'] ?? 0;
    final watching = stats['watching'] ?? 0;
    final completed = stats['completed'] ?? 0;
    final planToWatch = stats['planToWatch'] ?? 0;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.bar_chart,
                  color: selectedProfile?.color ?? Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Overview',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn(
                  context,
                  'Total',
                  total,
                  Icons.library_books,
                  selectedProfile?.color ?? Colors.grey,
                ),
                _buildStatColumn(
                  context,
                  'Watching',
                  watching,
                  Icons.play_circle_outline,
                  Colors.blue,
                ),
                _buildStatColumn(
                  context,
                  'Completed',
                  completed,
                  Icons.check_circle_outline,
                  Colors.green,
                ),
                _buildStatColumn(
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
    );
  }

  Widget _buildStatColumn(
    BuildContext context,
    String label,
    int value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value.toString(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
        ),
      ],
    );
  }

  Widget _buildStatusBreakdownCard(BuildContext context, Map<String, dynamic> stats) {
    final statusCounts = stats['statusCounts'] as Map<ContentStatus, int>? ?? {};
    final total = stats['total'] ?? 1;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.pie_chart,
                  color: selectedProfile?.color ?? Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Status Breakdown',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...ContentStatus.values.map((status) {
              final count = statusCounts[status] ?? 0;
              final percentage = total > 0 ? (count / total * 100).toStringAsFixed(1) : '0.0';
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(_getStatusIcon(status), size: 20, color: _getStatusColor(status)),
                            const SizedBox(width: 8),
                            Text(status.displayName),
                          ],
                        ),
                        Text(
                          '$count ($percentage%)',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: total > 0 ? count / total : 0,
                      backgroundColor: Colors.grey.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation(_getStatusColor(status)),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeBreakdownCard(BuildContext context, Map<String, dynamic> stats) {
    final typeCounts = stats['typeCounts'] as Map<ContentType, int>? ?? {};
    final total = stats['total'] ?? 1;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.category,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Type Breakdown',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...ContentType.values.map((type) {
              final count = typeCounts[type] ?? 0;
              if (count == 0) return const SizedBox.shrink();

              final percentage = total > 0 ? (count / total * 100).toStringAsFixed(1) : '0.0';
              final profile = ProfileType.values.firstWhere(
                (p) => p.contentType == type,
                orElse: () => ProfileType.anime,
              );

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(profile.icon, size: 20, color: profile.color),
                            const SizedBox(width: 8),
                            Text(type.displayName),
                          ],
                        ),
                        Text(
                          '$count ($percentage%)',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: total > 0 ? count / total : 0,
                      backgroundColor: Colors.grey.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation(profile.color),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdownCard(BuildContext context, Map<String, dynamic> stats) {
    final categoryCounts = stats['categoryCounts'] as Map<String, int>? ?? {};

    if (categoryCounts.isEmpty) {
      return const SizedBox.shrink();
    }

    final total = categoryCounts.values.fold(0, (sum, count) => sum + count);
    final sortedCategories = categoryCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.label,
                  color: selectedProfile?.color ?? Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Category Breakdown',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...sortedCategories.map((entry) {
              final percentage = total > 0 ? (entry.value / total * 100).toStringAsFixed(1) : '0.0';
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key),
                        Text(
                          '${entry.value} ($percentage%)',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: total > 0 ? entry.value / total : 0,
                      backgroundColor: Colors.grey.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation(
                        selectedProfile?.color ?? Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              );
            }),
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

  Color _getStatusColor(ContentStatus status) {
    switch (status) {
      case ContentStatus.watching:
        return Colors.blue;
      case ContentStatus.completed:
        return Colors.green;
      case ContentStatus.planToWatch:
        return Colors.orange;
      case ContentStatus.onHold:
        return Colors.amber;
      case ContentStatus.dropped:
        return Colors.red;
    }
  }

  Future<Map<String, dynamic>> _fetchAllStats() async {
    final db = DatabaseService();

    List<ContentItem> allItems;
    if (selectedProfile != null) {
      allItems = await db.getContentItemsByType(selectedProfile!.contentType);
    } else {
      allItems = await db.getAllContentItems();
    }

    // Status counts
    final statusCounts = <ContentStatus, int>{};
    for (final status in ContentStatus.values) {
      statusCounts[status] = allItems.where((item) => item.status == status).length;
    }

    // Type counts (only if no profile selected)
    final typeCounts = <ContentType, int>{};
    if (selectedProfile == null) {
      for (final type in ContentType.values) {
        typeCounts[type] = allItems.where((item) => item.type == type).length;
      }
    }

    // Category counts
    final categoryCounts = <String, int>{};
    for (final item in allItems) {
      if (item.category != null && item.category!.isNotEmpty) {
        categoryCounts[item.category!] = (categoryCounts[item.category!] ?? 0) + 1;
      }
    }

    return {
      'total': allItems.length,
      'watching': statusCounts[ContentStatus.watching] ?? 0,
      'completed': statusCounts[ContentStatus.completed] ?? 0,
      'planToWatch': statusCounts[ContentStatus.planToWatch] ?? 0,
      'statusCounts': statusCounts,
      'typeCounts': typeCounts,
      'categoryCounts': categoryCounts,
    };
  }
}
