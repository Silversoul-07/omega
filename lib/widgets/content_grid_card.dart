import 'package:flutter/material.dart';
import '../models/content_item.dart';
import '../models/enums.dart';
import 'content_details_bottom_sheet.dart';

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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _getTypeColor(item.type).withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
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
                            _getTypeColor(item.type).withOpacity(0.8),
                            _getTypeColor(item.type).withOpacity(0.5),
                            _getTypeColor(item.type).withOpacity(0.3),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                      child: Icon(
                        _getTypeIcon(item.type),
                        size: 72,
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                  // Progress overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.9),
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (item.total > 0)
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: _getStatusColor(item.status)
                                        .withOpacity(0.3),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: item.progress / item.total,
                                  backgroundColor: Colors.white.withOpacity(0.2),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _getStatusColor(item.status),
                                  ),
                                  minHeight: 5,
                                ),
                              ),
                            ),
                          if (item.total > 0) const SizedBox(height: 6),
                          Text(
                            item.progressDisplay,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Status badge
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(item.status),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: _getStatusColor(item.status).withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        _getStatusShort(item.status),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  if (item.category != null && item.category!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.teal.withOpacity(0.15),
                            Colors.teal.withOpacity(0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.teal.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        item.category!,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.teal.shade700,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
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

  void _showDetailsDialog(BuildContext context) {
    ContentDetailsBottomSheet.show(
      context,
      item,
      onChanged: onChanged,
    );
  }
}
