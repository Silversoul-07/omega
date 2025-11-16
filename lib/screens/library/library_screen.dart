import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/content_item.dart';
import '../../models/custom_list.dart';
import '../../models/profile_type.dart';
import '../../services/database_service.dart';
import '../../widgets/add_content_fab.dart';
import '../../widgets/content_grid_card.dart';
import 'add_edit_list_dialog.dart';

/// Library screen - Custom lists with tab navigation
/// Similar to Shelves but with user-created list tabs
class LibraryScreen extends StatefulWidget {
  final ProfileType? selectedProfile;
  final Function(ProfileType) onProfileChange;

  const LibraryScreen({
    super.key,
    this.selectedProfile,
    required this.onProfileChange,
  });

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  final _db = DatabaseService();
  late TabController _tabController;
  List<CustomList> _lists = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeLibrary();
  }

  Future<void> _initializeLibrary() async {
    // Ensure Favourites list exists
    await _db.ensureFavouritesListExists();
    await _loadLists();
  }

  Future<void> _loadLists() async {
    setState(() => _isLoading = true);

    try {
      final lists = await _db.getAllLists();

      if (mounted) {
        setState(() {
          _lists = lists;
          _isLoading = false;
        });

        // Initialize tab controller with current list count
        _tabController = TabController(
          length: _lists.length,
          vsync: this,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading lists: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    if (!_isLoading && _lists.isNotEmpty) {
      _tabController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_lists.isEmpty) {
      return _buildEmptyState();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Library',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            onPressed: _createNewList,
            tooltip: 'Create new list',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _lists.map((list) => _buildTab(list)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _lists.map((list) => _buildListTab(list)).toList(),
      ),
      floatingActionButton: AddContentFAB(
        selectedProfile: widget.selectedProfile,
        onContentAdded: () => setState(() {}),
      ),
    );
  }

  Widget _buildTab(CustomList list) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(list.icon ?? '📚', style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(list.name),
          if (!list.isSystem) ...[
            const SizedBox(width: 4),
            PopupMenuButton(
              icon: const Icon(Icons.more_vert, size: 16),
              padding: EdgeInsets.zero,
              tooltip: 'List options',
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'export',
                  child: Row(
                    children: [
                      Icon(Icons.share, size: 18),
                      SizedBox(width: 8),
                      Text('Export'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'edit') {
                  _editList(list);
                } else if (value == 'export') {
                  _exportList(list);
                } else if (value == 'delete') {
                  _confirmDeleteList(list);
                }
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildListTab(CustomList list) {
    return FutureBuilder<List<ContentItem>>(
      future: _db.getContentInList(list.id),
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
              ],
            ),
          );
        }

        final items = snapshot.data ?? [];

        if (items.isEmpty) {
          return _buildEmptyListState(list);
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.55,
              crossAxisSpacing: 8,
              mainAxisSpacing: 12,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return _buildContentCardWithRemove(items[index], list);
            },
          ),
        );
      },
    );
  }

  Widget _buildContentCardWithRemove(ContentItem item, CustomList list) {
    return Stack(
      children: [
        ContentGridCard(
          item: item,
          onChanged: () => setState(() {}),
        ),
        // Remove from list button
        if (!list.isSystem)
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 16),
                iconSize: 16,
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
                onPressed: () => _removeFromList(item, list),
                tooltip: 'Remove from list',
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyListState(CustomList list) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              list.icon ?? '📚',
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            Text(
              '${list.name} is empty',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Add content to this list from the content details page',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                // Switch to Add tab to add new content
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('💡 Tip: Use the + button to add content, then add it to this list from the content details page'),
                    duration: Duration(seconds: 4),
                  ),
                );
              },
              icon: const Icon(Icons.info_outline),
              label: const Text('How to add content'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Library',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.library_books_outlined,
                size: 100,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              ),
              const SizedBox(height: 24),
              Text(
                'No Lists Yet',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Create custom lists to organize your content',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _createNewList,
                icon: const Icon(Icons.add),
                label: const Text('Create Your First List'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _removeFromList(ContentItem item, CustomList list) async {
    try {
      await _db.removeContentFromList(list.id, item.id);

      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed "${item.title}" from ${list.name}'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
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

  Future<void> _createNewList() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const AddEditListDialog(),
    );

    if (result == true && mounted) {
      await _loadLists();
    }
  }

  Future<void> _editList(CustomList list) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AddEditListDialog(list: list),
    );

    if (result == true && mounted) {
      await _loadLists();
    }
  }

  Future<void> _exportList(CustomList list) async {
    // Import share_plus for export
    try {
      final items = await _db.getContentInList(list.id);

      final exportData = {
        'app': 'Content Tracker',
        'version': '1.0',
        'list_name': list.name,
        'list_description': list.description,
        'list_icon': list.icon,
        'created_at': list.createdAt.toIso8601String(),
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

      // For now, show a dialog with the JSON
      // TODO: Use share_plus package once available
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Export: ${list.name}'),
            content: SingleChildScrollView(
              child: SelectableText(
                const JsonEncoder.withIndent('  ').convert(exportData),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
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

  Future<void> _confirmDeleteList(CustomList list) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete List?'),
        content: Text(
          'Are you sure you want to delete "${list.name}"?\n\nThis will not delete the content items, only the list itself.',
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
        await _db.deleteList(list.id);

        if (mounted) {
          await _loadLists();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Deleted "${list.name}"'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting list: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
