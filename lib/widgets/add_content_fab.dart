import 'package:flutter/material.dart';
import '../screens/add/add_content_screen.dart';
import '../models/profile_type.dart';

/// Shared Floating Action Button for adding content
/// Used on Home, Shelves, and Library screens
class AddContentFAB extends StatelessWidget {
  final ProfileType? selectedProfile;
  final VoidCallback? onContentAdded;

  const AddContentFAB({
    super.key,
    this.selectedProfile,
    this.onContentAdded,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _openAddScreen(context),
      icon: const Icon(Icons.add),
      label: const Text('Add'),
      tooltip: 'Add new content',
    );
  }

  Future<void> _openAddScreen(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddContentScreen(
          selectedProfile: selectedProfile,
        ),
      ),
    );

    // If content was added, trigger callback to refresh parent screen
    if (result == true && onContentAdded != null) {
      onContentAdded!();
    }
  }
}
