import 'package:flutter/material.dart';
import '../../models/custom_list.dart';
import '../../models/content_item.dart';
import '../../services/database_service.dart';
import '../../widgets/content_grid_card.dart';
import 'add_edit_list_dialog.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';

/// Detail screen for a custom list showing all content
class ListDetailScreen extends StatefulWidget {
  final CustomList list;

  const ListDetailScreen({super.key, required this.list});

  @override
  State<ListDetailScreen> createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends State<ListDetailScreen> {
  final _db = DatabaseService();
  late CustomList _list;

  @override
  void initState() {
    super.initState();
    _list = widget.list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              _list.icon ?? '📚',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _list.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _exportList,
            tooltip: 'Export list',
          ),
          if (!_list.isSystem)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _editList,
              tooltip: 'Edit list',
            ),
          if (!_list.isSystem)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _confirmDelete,
              tooltip: 'Delete list',
            ),
        ],
      ),
      body: Column(
        children: [
          if (_list.description != null && _list.description!.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
              ),
              child: Text(
                _list.description!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade700,
                    ),
              ),
            ),
          Expanded(child: _buildContentGrid()),
        ],
      ),
    );
  }

  Widget _buildContentGrid() {
    return FutureBuilder<List<ContentItem>>(
      future: _db.getContentInList(_list.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading content',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
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
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.55,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildContentCard(item);
            },
          ),
        );
      },
    );
  }

  Widget _buildContentCard(ContentItem item) {
    return Stack(
      children: [
        ContentGridCard(
          item: item,
          onChanged: () => setState(() {}),
        ),
        // Remove button
        Positioned(
          top: 4,
          left: 4,
          child: Material(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: () => _removeFromList(item),
              borderRadius: BorderRadius.circular(16),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _list.icon ?? '📚',
              style: const TextStyle(fontSize: 80),
            ),
            const SizedBox(height: 16),
            Text(
              'Empty List',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Add content to "${_list.name}" from the content details page',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              '💡 Tip: Open any content and tap "Add to List"',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _removeFromList(ContentItem item) async {
    try {
      await _db.removeContentFromList(_list.id, item.id);
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed "${item.title}" from list'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () async {
                await _db.addContentToList(_list.id, item.id);
                setState(() {});
              },
            ),
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

  Future<void> _editList() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AddEditListDialog(list: _list),
    );

    if (result == true && mounted) {
      // Reload list
      final updated = await _db.getListById(_list.id);
      if (updated != null) {
        setState(() => _list = updated);
      }
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete List?'),
        content: Text(
          'Are you sure you want to delete "${_list.name}"?\n\nThis will not delete the content items, only the list itself.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _db.deleteList(_list.id);
        if (mounted) {
          Navigator.pop(context, true); // Return to library
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Deleted "${_list.name}"'),
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

  Future<void> _exportList() async {
    try {
      final items = await _db.getContentInList(_list.id);

      final exportData = {
        'app': 'Content Tracker',
        'version': '1.0',
        'list_name': _list.name,
        'list_description': _list.description,
        'list_icon': _list.icon,
        'created_at': _list.createdAt.toIso8601String(),
        'items': items.map((item) => {
          'title': item.title,
          'type': item.type.toString().split('.').last,
          'status': item.status.toString().split('.').last,
          'progress': item.progress,
          'total': item.total,
          'category': item.category,
          'notes': item.notes,
        }).toList(),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

      await Share.share(
        jsonString,
        subject: 'Export: ${_list.name}',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('List exported!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
