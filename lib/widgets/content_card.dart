import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shimmer/shimmer.dart';
import '../models/content_item.dart';
import '../models/enums.dart';
import '../services/database_service.dart';

/// Reusable card widget for displaying content items with modern animations
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap ?? () => _showDetailsDialog(context),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Modern image placeholder with shimmer
                _buildImagePlaceholder(context, isDark),
                const SizedBox(width: 16),
                // Content details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
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
                      const SizedBox(height: 12),
                      // Modern progress bar
                      _buildProgressSection(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate()
      .fadeIn(duration: 300.ms, curve: Curves.easeOut)
      .slideY(begin: 0.1, end: 0, duration: 300.ms, curve: Curves.easeOut);
  }

  Widget _buildImagePlaceholder(BuildContext context, bool isDark) {
    return Hero(
      tag: 'content_${item.id}',
      child: Container(
        width: 70,
        height: 100,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.8),
              Theme.of(context).colorScheme.secondary.withOpacity(0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          _getTypeIcon(item.type),
          color: Colors.white,
          size: 36,
        ),
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context) {
    final progress = item.total > 0 ? item.progress / item.total : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
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
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: Theme.of(context)
                .colorScheme
                .primaryContainer
                .withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChip(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 11,
              letterSpacing: 0.3,
            ),
      ),
    );
  }

  IconData _getTypeIcon(ContentType type) {
    switch (type) {
      case ContentType.anime:
        return PhosphorIconsRegular.play;
      case ContentType.comic:
        return PhosphorIconsRegular.book;
      case ContentType.novel:
        return PhosphorIconsRegular.bookOpen;
      case ContentType.movie:
        return PhosphorIconsRegular.film;
      case ContentType.tvSeries:
        return PhosphorIconsRegular.television;
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _ContentDetailsDialog(
          item: item,
          onChanged: onChanged,
        );
      },
    );
  }
}

/// Dialog for viewing and editing content item details
class _ContentDetailsDialog extends StatefulWidget {
  final ContentItem item;
  final VoidCallback? onChanged;

  const _ContentDetailsDialog({
    required this.item,
    this.onChanged,
  });

  @override
  State<_ContentDetailsDialog> createState() => _ContentDetailsDialogState();
}

class _ContentDetailsDialogState extends State<_ContentDetailsDialog> {
  late int _currentProgress;
  late ContentStatus _currentStatus;
  final _db = DatabaseService();

  @override
  void initState() {
    super.initState();
    _currentProgress = widget.item.progress;
    _currentStatus = widget.item.status;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.item.title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type and Status
            Row(
              children: [
                Chip(
                  label: Text(widget.item.type.displayName),
                  avatar: Icon(
                    _getTypeIcon(widget.item.type),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<ContentStatus>(
                    initialValue: _currentStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: ContentStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status.displayName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _currentStatus = value);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Progress
            Text(
              'Progress: $_currentProgress / ${widget.item.total}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Slider(
              value: _currentProgress.toDouble(),
              min: 0,
              max: widget.item.total.toDouble(),
              divisions: widget.item.total > 0 ? widget.item.total : 1,
              label: _currentProgress.toString(),
              onChanged: (value) {
                setState(() => _currentProgress = value.toInt());
              },
            ),
            const SizedBox(height: 8),
            // Notes
            if (widget.item.notes != null && widget.item.notes!.isNotEmpty) ...[
              Text(
                'Notes:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.item.notes!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
            ],
            // Dates
            Text(
              'Added: ${_formatDate(widget.item.createdAt)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            if (widget.item.createdAt != widget.item.updatedAt)
              Text(
                'Updated: ${_formatDate(widget.item.updatedAt)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => _saveChanges(context),
          child: const Text('Save'),
        ),
      ],
    );
  }

  IconData _getTypeIcon(ContentType type) {
    switch (type) {
      case ContentType.anime:
        return PhosphorIconsRegular.play;
      case ContentType.comic:
        return PhosphorIconsRegular.book;
      case ContentType.novel:
        return PhosphorIconsRegular.bookOpen;
      case ContentType.movie:
        return PhosphorIconsRegular.film;
      case ContentType.tvSeries:
        return PhosphorIconsRegular.television;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _saveChanges(BuildContext context) async {
    try {
      final updatedItem = widget.item
        ..progress = _currentProgress
        ..status = _currentStatus
        ..updatedAt = DateTime.now();

      // Auto-complete if progress reaches total
      if (updatedItem.total > 0 && updatedItem.progress >= updatedItem.total) {
        updatedItem.status = ContentStatus.completed;
      }

      await _db.updateContentItem(updatedItem);

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onChanged?.call();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
