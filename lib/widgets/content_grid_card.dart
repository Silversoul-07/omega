import 'package:flutter/material.dart';
import '../models/content_item.dart';
import '../models/enums.dart';
import '../screens/content_details/content_details_screen.dart';

/// IMDB/MAL style grid card for content items
class ContentGridCard extends StatelessWidget {
  final ContentItem item;
  final VoidCallback? onTap;
  final VoidCallback? onChanged;

  const ContentGridCard({
    super.key,
    required this.item,
    this.onTap,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap ?? () => _showDetailsDialog(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster/Cover image
            AspectRatio(
              aspectRatio: 2 / 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _getTypeColor(item.type).withOpacity(0.6),
                          _getTypeColor(item.type).withOpacity(0.3),
                        ],
                      ),
                    ),
                    child: Icon(
                      _getTypeIcon(item.type),
                      size: 64,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                  // Progress overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.8),
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (item.total > 0)
                            LinearProgressIndicator(
                              value: item.progress / item.total,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getStatusColor(item.status),
                              ),
                            ),
                          if (item.total > 0) const SizedBox(height: 4),
                          Text(
                            item.progressDisplay,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Status badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(item.status),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getStatusShort(item.status),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content details
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (item.category != null && item.category!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: Colors.teal.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        item.category!,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.teal.shade700,
                          fontWeight: FontWeight.bold,
                        ),
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

  String _getStatusShort(ContentStatus status) {
    switch (status) {
      case ContentStatus.watching:
        return 'NOW';
      case ContentStatus.completed:
        return 'DONE';
      case ContentStatus.planToWatch:
        return 'PLAN';
      case ContentStatus.onHold:
        return 'HOLD';
      case ContentStatus.dropped:
        return 'DROP';
    }
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

  Color _getTypeColor(ContentType type) {
    switch (type) {
      case ContentType.anime:
        return const Color(0xFF2196F3); // Blue
      case ContentType.comic:
        return const Color(0xFFFF9800); // Orange
      case ContentType.novel:
        return const Color(0xFF4CAF50); // Green
      case ContentType.movie:
        return const Color(0xFFF44336); // Red
      case ContentType.tvSeries:
        return const Color(0xFF9C27B0); // Purple
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

  void _showDetailsDialog(BuildContext context) async {
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
}
