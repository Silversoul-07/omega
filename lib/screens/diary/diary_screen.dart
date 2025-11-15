import 'package:flutter/material.dart';
import '../../models/content_item.dart';
import '../../models/enums.dart';
import '../../models/profile_type.dart';
import '../../services/database_service.dart';
import '../content_details/content_details_screen.dart';

/// Diary screen - Letterboxd style activity feed
class DiaryScreen extends StatefulWidget {
  final ProfileType? selectedProfile;
  final Function(ProfileType) onProfileChange;

  const DiaryScreen({
    super.key,
    this.selectedProfile,
    required this.onProfileChange,
  });

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final _db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Diary',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<ContentItem>>(
        future: _fetchDiaryEntries(),
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
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return _buildDiaryEntry(item);
              },
            ),
          );
        },
      ),
    );
  }

  Future<List<ContentItem>> _fetchDiaryEntries() async {
    // Get all items, sorted by updatedAt (most recent first)
    List<ContentItem> items;

    if (widget.selectedProfile == null) {
      items = await _db.getAllContentItems();
    } else {
      items = await _db.getContentItemsByType(widget.selectedProfile!.contentType);
    }

    // Sort by most recently updated
    items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return items;
  }

  Widget _buildDiaryEntry(ContentItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _openDetailsPage(item),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date badge
              Container(
                width: 60,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getTypeColor(item.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getTypeColor(item.type).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      _getMonthName(item.updatedAt.month),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getTypeColor(item.type),
                      ),
                    ),
                    Text(
                      item.updatedAt.day.toString(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _getTypeColor(item.type),
                      ),
                    ),
                    Text(
                      item.updatedAt.year.toString(),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Content info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _buildChip(
                          context,
                          item.type.displayName,
                          _getTypeColor(item.type),
                        ),
                        _buildChip(
                          context,
                          item.status.displayName,
                          _getStatusColor(item.status),
                        ),
                        if (item.category != null && item.category!.isNotEmpty)
                          _buildChip(
                            context,
                            item.category!,
                            Colors.teal,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.visibility,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.progressDisplay,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                        ),
                        const Spacer(),
                        Text(
                          _getTimeAgo(item.updatedAt),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                                fontStyle: FontStyle.italic,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
      ),
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
              Icons.auto_stories_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Activity Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Your content activity will appear here',
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

  String _getMonthName(int month) {
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
                    'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return months[month - 1];
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  Color _getTypeColor(ContentType type) {
    switch (type) {
      case ContentType.anime:
        return const Color(0xFF2196F3);
      case ContentType.comic:
        return const Color(0xFFFF9800);
      case ContentType.novel:
        return const Color(0xFF4CAF50);
      case ContentType.movie:
        return const Color(0xFFF44336);
      case ContentType.tvSeries:
        return const Color(0xFF9C27B0);
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
        return Colors.purple;
      case ContentStatus.dropped:
        return Colors.red;
    }
  }

  void _openDetailsPage(ContentItem item) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContentDetailsScreen(item: item),
      ),
    );

    // Refresh if content was updated
    if (result == true && mounted) {
      setState(() {});
    }
  }
}
