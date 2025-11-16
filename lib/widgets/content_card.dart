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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: onTap ?? () => _showDetailsDialog(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Premium thumbnail with Material You colors
                _buildThumbnail(context),
                const SizedBox(width: 16),
                // Content details with perfect typography
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title with perfect line height
                      Text(
                        item.title,
                        style: theme.textTheme.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Metadata chips
                      _buildMetadataRow(context),
                      const SizedBox(height: 12),
                      // Progress indicator
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
      .fadeIn(duration: 250.ms, curve: Curves.easeOut)
      .slideY(begin: 0.05, end: 0, duration: 250.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildThumbnail(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Hero(
      tag: 'content_${item.id}',
      child: Container(
        width: 80,
        height: 112,
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Icon(
            _getTypeIcon(item.type),
            color: colorScheme.onPrimaryContainer,
            size: 40,
          ),
        ),
      ),
    );
  }

  Widget _buildMetadataRow(BuildContext context) {
    return Row(
      children: [
        _buildChip(context, item.type.displayName, _getTypeColor(context)),
        const SizedBox(width: 8),
        _buildChip(context, item.status.displayName, _getStatusColor(context, item.status)),
      ],
    );
  }

  Widget _buildProgressSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progress = item.total > 0 ? item.progress / item.total : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              item.progressDisplay,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          minHeight: 4,
          backgroundColor: colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          borderRadius: BorderRadius.circular(2),
        ),
      ],
    );
  }

  Widget _buildChip(BuildContext context, String label, Color backgroundColor) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall,
      ),
    );
  }

  Color _getTypeColor(BuildContext context) {
    return Theme.of(context).colorScheme.secondaryContainer;
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
    final colorScheme = Theme.of(context).colorScheme;

    switch (status) {
      case ContentStatus.watching:
        return colorScheme.tertiaryContainer;
      case ContentStatus.completed:
        return colorScheme.primaryContainer;
      case ContentStatus.planToWatch:
        return colorScheme.secondaryContainer;
      case ContentStatus.onHold:
        return colorScheme.surfaceContainerHighest;
      case ContentStatus.dropped:
        return colorScheme.errorContainer;
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
