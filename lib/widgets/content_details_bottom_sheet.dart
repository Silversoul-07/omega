import 'package:flutter/material.dart';
import '../models/content_item.dart';
import '../models/enums.dart';
import '../services/database_service.dart';

/// Modern bottom sheet for viewing and editing content details
class ContentDetailsBottomSheet extends StatefulWidget {
  final ContentItem item;
  final VoidCallback? onChanged;

  const ContentDetailsBottomSheet({
    super.key,
    required this.item,
    this.onChanged,
  });

  static Future<void> show(
    BuildContext context,
    ContentItem item, {
    VoidCallback? onChanged,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ContentDetailsBottomSheet(
        item: item,
        onChanged: onChanged,
      ),
    );
  }

  @override
  State<ContentDetailsBottomSheet> createState() =>
      _ContentDetailsBottomSheetState();
}

class _ContentDetailsBottomSheetState extends State<ContentDetailsBottomSheet> {
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
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        widget.item.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      // Type and Category chips
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Chip(
                            label: Text(widget.item.type.displayName),
                            avatar: Icon(
                              _getTypeIcon(widget.item.type),
                              size: 18,
                            ),
                            backgroundColor: _getTypeColor(widget.item.type)
                                .withOpacity(0.1),
                          ),
                          if (widget.item.category != null &&
                              widget.item.category!.isNotEmpty)
                            Chip(
                              label: Text(widget.item.category!),
                              backgroundColor: Colors.teal.withOpacity(0.1),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Status Selector
                      Text(
                        'Status',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<ContentStatus>(
                        value: _currentStatus,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        items: ContentStatus.values.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Row(
                              children: [
                                Icon(
                                  _getStatusIcon(status),
                                  size: 18,
                                  color: _getStatusColor(status),
                                ),
                                const SizedBox(width: 8),
                                Text(status.displayName),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _currentStatus = value);
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      // Progress Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Progress',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            '$_currentProgress / ${widget.item.total}',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Quick action buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _currentProgress > 0
                                  ? () {
                                      setState(() {
                                        _currentProgress--;
                                      });
                                    }
                                  : null,
                              icon: const Icon(Icons.remove),
                              label: const Text('-1'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _currentProgress < widget.item.total
                                  ? () {
                                      setState(() {
                                        _currentProgress++;
                                      });
                                    }
                                  : null,
                              icon: const Icon(Icons.add),
                              label: const Text('+1'),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Progress slider
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
                      const SizedBox(height: 24),
                      // Notes section
                      if (widget.item.notes != null &&
                          widget.item.notes!.isNotEmpty) ...[
                        Text(
                          'Notes',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceVariant
                                .withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.item.notes!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      // Dates
                      _buildInfoRow(
                        'Added',
                        _formatDate(widget.item.createdAt),
                        Icons.calendar_today,
                      ),
                      if (widget.item.createdAt != widget.item.updatedAt) ...[
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          'Updated',
                          _formatDate(widget.item.updatedAt),
                          Icons.update,
                        ),
                      ],
                      const SizedBox(height: 24),
                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              onPressed: () => _saveChanges(context),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text('Save Changes'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
        ),
      ],
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

  IconData _getStatusIcon(ContentStatus status) {
    switch (status) {
      case ContentStatus.watching:
        return Icons.play_circle;
      case ContentStatus.completed:
        return Icons.check_circle;
      case ContentStatus.planToWatch:
        return Icons.bookmark;
      case ContentStatus.onHold:
        return Icons.pause_circle;
      case ContentStatus.dropped:
        return Icons.cancel;
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
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Updated successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        widget.onChanged?.call();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Error: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }
}
