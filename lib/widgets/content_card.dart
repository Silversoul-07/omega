import 'package:flutter/material.dart';
import '../models/content_item.dart';
import '../models/enums.dart';
import '../services/database_service.dart';
import '../screens/content_details/content_details_screen.dart';

/// Reusable card widget for displaying content items
class ContentCard extends StatelessWidget {
  final ContentItem item;
  final VoidCallback? onTap;
  final VoidCallback? onChanged;

  const ContentCard({
    super.key,
    required this.item,
    this.onTap,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap ?? () => _openDetailsPage(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Placeholder image
              Container(
                width: 60,
                height: 90,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getTypeIcon(item.type),
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
              ),
              const SizedBox(width: 12),
              // Content details
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
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _buildChip(
                          context,
                          item.type.displayName,
                          Theme.of(context).colorScheme.primary,
                        ),
                        _buildChip(
                          context,
                          item.status.displayName,
                          _getStatusColor(context, item.status),
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
                    // Progress bar
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progress',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              item.progressDisplay,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: item.total > 0 ? item.progress / item.total : 0,
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withOpacity(0.3),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Quick action buttons
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.filledTonal(
                    onPressed: () => _updateProgress(context, item.progress + 1),
                    icon: const Icon(Icons.add, size: 18),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                  ),
                  const SizedBox(height: 4),
                  IconButton.filledTonal(
                    onPressed: item.progress > 0
                        ? () => _updateProgress(context, item.progress - 1)
                        : null,
                    icon: const Icon(Icons.remove, size: 18),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                  ),
                ],
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

  IconData _getTypeIcon(ContentType type) {
    switch (type) {
      case ContentType.anime:
        return Icons.animation;
      case ContentType.comic:
        return Icons.auto_stories;
      case ContentType.novel:
        return Icons.menu_book;
      case ContentType.movie:
        return Icons.movie;
      case ContentType.tvSeries:
        return Icons.tv;
    }
  }

  Color _getStatusColor(BuildContext context, ContentStatus status) {
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

  void _openDetailsPage(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContentDetailsScreen(item: item),
      ),
    );

    // Refresh if content was updated
    if (result == true) {
      onChanged?.call();
    }
  }

  Future<void> _updateProgress(BuildContext context, int newProgress) async {
    final db = DatabaseService();
    try {
      final updatedItem = item
        ..progress = newProgress
        ..updatedAt = DateTime.now();

      // Auto-complete if progress reaches total
      if (updatedItem.total > 0 && updatedItem.progress >= updatedItem.total) {
        updatedItem.status = ContentStatus.completed;
      }

      await db.updateContentItem(updatedItem);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Progress updated to $newProgress'),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.green,
        ),
      );

      onChanged?.call();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
