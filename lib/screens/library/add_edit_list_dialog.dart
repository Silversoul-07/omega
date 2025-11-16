import 'package:flutter/material.dart';
import '../../models/custom_list.dart';
import '../../services/database_service.dart';

/// Dialog for creating or editing a custom list
class AddEditListDialog extends StatefulWidget {
  final CustomList? list; // If null, creating new list; if provided, editing

  const AddEditListDialog({super.key, this.list});

  @override
  State<AddEditListDialog> createState() => _AddEditListDialogState();
}

class _AddEditListDialogState extends State<AddEditListDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _db = DatabaseService();

  String _selectedEmoji = '📚';

  final List<String> _emojis = [
    '❤️', '⭐', '📚', '🎬', '📺', '🎮', '🎵', '🎨',
    '✨', '🔥', '💎', '🏆', '🎯', '🚀', '💫', '🌟',
    '📖', '🎭', '🎪', '🎨', '🎬', '📽️', '🎞️', '🎥',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.list != null) {
      _nameController.text = widget.list!.name;
      _descriptionController.text = widget.list!.description ?? '';
      _selectedEmoji = widget.list!.icon ?? '📚';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.list != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit List' : 'Create New List'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emoji picker
              Text(
                'Icon',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Container(
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: _emojis.length,
                  itemBuilder: (context, index) {
                    final emoji = _emojis[index];
                    final isSelected = emoji == _selectedEmoji;
                    return InkWell(
                      onTap: () => setState(() => _selectedEmoji = emoji),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primaryContainer
                              : null,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Name field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'List Name *',
                  hintText: 'e.g., Favourites, To Watch, Classics',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  if (value.trim().length > 50) {
                    return 'Name too long (max 50 characters)';
                  }
                  return null;
                },
                autofocus: !isEditing,
              ),
              const SizedBox(height: 16),

              // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'Add a short description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                maxLength: 200,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saveList,
          child: Text(isEditing ? 'Save' : 'Create'),
        ),
      ],
    );
  }

  Future<void> _saveList() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      if (widget.list != null) {
        // Editing existing list
        final updatedList = widget.list!
          ..name = _nameController.text.trim()
          ..description = _descriptionController.text.trim().isNotEmpty
              ? _descriptionController.text.trim()
              : null
          ..icon = _selectedEmoji;

        await _db.updateList(updatedList);

        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Updated "${updatedList.name}"'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Creating new list
        final allLists = await _db.getAllLists();
        final newOrder = allLists.isEmpty ? 0 : allLists.map((l) => l.order).reduce((a, b) => a > b ? a : b) + 1;

        final newList = CustomList(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isNotEmpty
              ? _descriptionController.text.trim()
              : null,
          icon: _selectedEmoji,
          order: newOrder,
        );

        await _db.createList(newList);

        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Created "${newList.name}"'),
              backgroundColor: Colors.green,
            ),
          );
        }
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
}
