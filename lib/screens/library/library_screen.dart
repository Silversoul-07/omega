import 'package:flutter/material.dart';
import '../../models/custom_list.dart';
import '../../models/profile_type.dart';
import '../../services/database_service.dart';
import '../../widgets/add_content_fab.dart';
import 'list_detail_screen.dart';
import 'add_edit_list_dialog.dart';

/// Library screen - Custom lists management
/// Phase 2: Shows all custom lists with create/edit/delete functionality
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

class _LibraryScreenState extends State<LibraryScreen> {
  final _db = DatabaseService();

  @override
  void initState() {
    super.initState();
    _ensureFavouritesExists();
  }

  Future<void> _ensureFavouritesExists() async {
    await _db.ensureFavouritesListExists();
  }

  @override
  Widget build(BuildContext context) {
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
      ),
      body: _buildListsGrid(),
      floatingActionButton: AddContentFAB(
        selectedProfile: widget.selectedProfile,
        onContentAdded: () => setState(() {}),
      ),
    );
  }

  Widget _buildListsGrid() {
    return FutureBuilder<List<CustomList>>(
      future: _db.getAllLists(),
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
                  'Error loading lists',
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

        final lists = snapshot.data ?? [];

        if (lists.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: lists.length + 1, // +1 for "Create New List" card
            itemBuilder: (context, index) {
              if (index == lists.length) {
                return _buildCreateListCard();
              }
              return _buildListCard(lists[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildListCard(CustomList list) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: () => _openListDetail(list),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon and menu
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primaryContainer,
                    Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Text(
                    list.icon ?? '📚',
                    style: const TextStyle(fontSize: 28),
                  ),
                  const Spacer(),
                  if (!list.isSystem)
                    PopupMenuButton(
                      icon: const Icon(Icons.more_vert, size: 20),
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
                        } else if (value == 'delete') {
                          _confirmDeleteList(list);
                        }
                      },
                    ),
                ],
              ),
            ),
            // List info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      list.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (list.description != null && list.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        list.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.movie,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${list.itemCount} ${list.itemCount == 1 ? 'item' : 'items'}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.bold,
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
      ),
    );
  }

  Widget _buildCreateListCard() {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
      child: InkWell(
        onTap: _createNewList,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              'Create New List',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
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
    );
  }

  Future<void> _openListDetail(CustomList list) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListDetailScreen(list: list),
      ),
    );

    if (result == true && mounted) {
      setState(() {});
    }
  }

  Future<void> _createNewList() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const AddEditListDialog(),
    );

    if (result == true && mounted) {
      setState(() {});
    }
  }

  Future<void> _editList(CustomList list) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AddEditListDialog(list: list),
    );

    if (result == true && mounted) {
      setState(() {});
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
        setState(() {});
        if (mounted) {
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
