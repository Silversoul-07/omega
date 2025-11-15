import 'package:flutter/material.dart';
import '../models/content_item.dart';
import '../models/enums.dart';
import 'content_details_bottom_sheet.dart';

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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _getTypeColor(item.type).withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: onTap ?? () => _showDetailsDialog(context),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Placeholder image with gradient
                Container(
                  width: 70,
                  height: 105,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _getTypeColor(item.type).withOpacity(0.8),
                        _getTypeColor(item.type).withOpacity(0.5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: _getTypeColor(item.type).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    _getTypeIcon(item.type),
                    color: Colors.white.withOpacity(0.6),
                    size: 36,
                  ),
                ),
              const SizedBox(width: 14),
              // Content details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            height: 1.3,
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
                    const SizedBox(height: 12),
                    // Progress bar
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progress',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            Text(
                              item.progressDisplay,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: item.total > 0 ? item.progress / item.total : 0,
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withOpacity(0.3),
                            minHeight: 6,
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

  Widget _buildChip(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
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

  void _showDetailsDialog(BuildContext context) {
    ContentDetailsBottomSheet.show(
      context,
      item,
      onChanged: onChanged,
    );
  }
}
