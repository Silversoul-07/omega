import 'package:flutter/material.dart';
import '../../models/content_item.dart';
import '../../models/enums.dart';
import '../../services/database_service.dart';

/// MAL/IMDB style content details page
class ContentDetailsScreen extends StatefulWidget {
  final ContentItem item;

  const ContentDetailsScreen({
    super.key,
    required this.item,
  });

  @override
  State<ContentDetailsScreen> createState() => _ContentDetailsScreenState();
}

class _ContentDetailsScreenState extends State<ContentDetailsScreen> {
  final _db = DatabaseService();
  late ContentItem _item;
  bool _isEditing = false;

  // Edit controllers
  late TextEditingController _titleController;
  late TextEditingController _notesController;
  late TextEditingController _categoryController;
  late TextEditingController _totalController;
  late int _currentProgress;
  late ContentStatus _currentStatus;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
    _initializeControllers();
  }

  void _initializeControllers() {
    _titleController = TextEditingController(text: _item.title);
    _notesController = TextEditingController(text: _item.notes ?? '');
    _categoryController = TextEditingController(text: _item.category ?? '');
    _totalController = TextEditingController(text: _item.total.toString());
    _currentProgress = _item.progress;
    _currentStatus = _item.status;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _categoryController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const Divider(height: 32),
                _buildProgressSection(),
                const Divider(height: 32),
                _buildDetailsSection(),
                const Divider(height: 32),
                _buildNotesSection(),
                const SizedBox(height: 32),
                if (_isEditing) _buildSaveButton(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getTypeColor(_item.type).withOpacity(0.8),
                _getTypeColor(_item.type).withOpacity(0.4),
              ],
            ),
          ),
          child: Center(
            child: Icon(
              _getTypeIcon(_item.type),
              size: 80,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(_isEditing ? Icons.close : Icons.edit),
          onPressed: () {
            setState(() {
              _isEditing = !_isEditing;
              if (!_isEditing) {
                // Reset controllers if canceling edit
                _initializeControllers();
              }
            });
          },
        ),
        PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'delete') {
              _confirmDelete();
            }
          },
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isEditing)
            TextField(
              controller: _titleController,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            )
          else
            Text(
              _item.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                label: Text(_item.type.displayName),
                avatar: Icon(_getTypeIcon(_item.type), size: 16),
                backgroundColor: _getTypeColor(_item.type).withOpacity(0.1),
              ),
              Chip(
                label: Text(_currentStatus.displayName),
                backgroundColor: _getStatusColor(_currentStatus).withOpacity(0.1),
              ),
              if (_item.category != null && _item.category!.isNotEmpty)
                Chip(
                  label: Text(_item.category!),
                  backgroundColor: Colors.teal.withOpacity(0.1),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (!_isEditing)
                Row(
                  children: [
                    IconButton.filled(
                      onPressed: _currentProgress > 0
                          ? () => _quickUpdateProgress(_currentProgress - 1)
                          : null,
                      icon: const Icon(Icons.remove),
                      iconSize: 20,
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: () => _quickUpdateProgress(_currentProgress + 1),
                      icon: const Icon(Icons.add),
                      iconSize: 20,
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '$_currentProgress / ${_item.total > 0 ? _item.total : '?'}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getTypeColor(_item.type),
                ),
          ),
          const SizedBox(height: 8),
          if (_item.total > 0) ...[
            LinearProgressIndicator(
              value: _currentProgress / _item.total,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getTypeColor(_item.type),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(_currentProgress / _item.total * 100).toStringAsFixed(1)}% Complete',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
          ],
          if (_isEditing) ...[
            const SizedBox(height: 16),
            Slider(
              value: _currentProgress.toDouble(),
              min: 0,
              max: _item.total > 0 ? _item.total.toDouble() : 100,
              divisions: _item.total > 0 ? _item.total : 100,
              label: _currentProgress.toString(),
              onChanged: (value) {
                setState(() => _currentProgress = value.toInt());
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Details',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            icon: Icons.category,
            label: 'Status',
            value: _isEditing
                ? null
                : _currentStatus.displayName,
            editWidget: _isEditing
                ? DropdownButtonFormField<ContentStatus>(
                    value: _currentStatus,
                    decoration: const InputDecoration(
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
                  )
                : null,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            icon: Icons.format_list_numbered,
            label: 'Total Episodes/Chapters',
            value: _isEditing ? null : (_item.total > 0 ? _item.total.toString() : 'Unknown'),
            editWidget: _isEditing
                ? TextField(
                    controller: _totalController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter total',
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            icon: Icons.label,
            label: 'Category',
            value: _isEditing ? null : (_item.category ?? 'No category'),
            editWidget: _isEditing
                ? TextField(
                    controller: _categoryController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter category/genre',
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            icon: Icons.calendar_today,
            label: 'Added',
            value: _formatDate(_item.createdAt),
          ),
          if (_item.createdAt != _item.updatedAt) ...[
            const SizedBox(height: 12),
            _buildDetailRow(
              icon: Icons.update,
              label: 'Last Updated',
              value: _formatDate(_item.updatedAt),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    String? value,
    Widget? editWidget,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
              const SizedBox(height: 4),
              if (editWidget != null)
                editWidget
              else if (value != null)
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notes',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          if (_isEditing)
            TextField(
              controller: _notesController,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Add your notes here...',
              ),
            )
          else
            Text(
              _item.notes?.isNotEmpty == true ? _item.notes! : 'No notes yet',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: _item.notes?.isNotEmpty == true
                        ? null
                        : Colors.grey.shade600,
                    fontStyle: _item.notes?.isNotEmpty == true
                        ? null
                        : FontStyle.italic,
                  ),
            ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: _saveChanges,
          icon: const Icon(Icons.save),
          label: const Text('Save Changes'),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _quickUpdateProgress(int newProgress) async {
    setState(() => _currentProgress = newProgress);

    try {
      final updatedItem = _item
        ..progress = _currentProgress
        ..updatedAt = DateTime.now();

      // Auto-complete if progress reaches total
      if (updatedItem.total > 0 && updatedItem.progress >= updatedItem.total) {
        updatedItem.status = ContentStatus.completed;
        setState(() => _currentStatus = ContentStatus.completed);
      }

      await _db.updateContentItem(updatedItem);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Progress updated to $_currentProgress'),
            duration: const Duration(seconds: 1),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveChanges() async {
    try {
      final updatedItem = _item
        ..title = _titleController.text
        ..progress = _currentProgress
        ..status = _currentStatus
        ..total = int.tryParse(_totalController.text) ?? 0
        ..category = _categoryController.text.isNotEmpty ? _categoryController.text : null
        ..notes = _notesController.text.isNotEmpty ? _notesController.text : null
        ..updatedAt = DateTime.now();

      // Auto-complete if progress reaches total
      if (updatedItem.total > 0 && updatedItem.progress >= updatedItem.total) {
        updatedItem.status = ContentStatus.completed;
      }

      await _db.updateContentItem(updatedItem);

      setState(() {
        _item = updatedItem;
        _isEditing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Changes saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate update
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Content?'),
        content: Text('Are you sure you want to delete "${_item.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _db.deleteContentItem(_item.id);
        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Content deleted'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
