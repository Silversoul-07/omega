import 'package:flutter/material.dart';
import 'dart:convert';
import '../../models/profile_type.dart';
import '../../models/content_item.dart';
import '../../models/custom_list.dart';
import '../../models/enums.dart';
import '../../scripts/seed_data.dart';
import '../../services/database_service.dart';
import 'stats_screen.dart';

/// Settings screen with theme and other preferences
class SettingsScreen extends StatelessWidget {
  final ThemeMode currentThemeMode;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ProfileType? selectedProfile;

  const SettingsScreen({
    super.key,
    required this.currentThemeMode,
    required this.onThemeChanged,
    this.selectedProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          _buildSectionHeader(context, 'Library'),
          _buildStatsTile(context),
          _buildImportListTile(context),
          const SizedBox(height: 16),
          _buildSectionHeader(context, 'Appearance'),
          _buildThemeOption(context),
          const SizedBox(height: 16),
          _buildSectionHeader(context, 'About'),
          _buildAboutTile(context),
          const SizedBox(height: 16),
          _buildSectionHeader(context, 'Developer'),
          _buildSeedDataTile(context),
          _buildResetDataTile(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildStatsTile(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(
          Icons.analytics,
          color: selectedProfile?.color ?? Theme.of(context).colorScheme.primary,
        ),
        title: const Text('Statistics'),
        subtitle: Text('View ${selectedProfile?.displayName ?? 'library'} stats'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StatsScreen(
                selectedProfile: selectedProfile,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImportListTile(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(
          Icons.download,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: const Text('Import List'),
        subtitle: const Text('Import a list from JSON'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showImportDialog(context),
      ),
    );
  }

  Widget _buildThemeOption(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              _getThemeIcon(currentThemeMode),
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Theme'),
            subtitle: Text(_getThemeLabel(currentThemeMode)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showThemeDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutTile(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(
          Icons.info_outline,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: const Text('About'),
        subtitle: const Text('Content Tracker v1.0.0'),
        onTap: () {
          showAboutDialog(
            context: context,
            applicationName: 'Content Tracker',
            applicationVersion: '1.0.0',
            applicationIcon: Icon(
              Icons.track_changes,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            children: [
              const Text(
                'An offline-first content tracking application for Anime, Comics, Novels, Movies, and TV Series.',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSeedDataTile(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(
          Icons.upload_file,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: const Text('Populate Test Data'),
        subtitle: const Text('Add sample content for testing'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showSeedDataDialog(context),
      ),
    );
  }

  Widget _buildResetDataTile(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(
          Icons.delete_forever,
          color: Colors.red,
        ),
        title: const Text('Reset All Data'),
        subtitle: const Text('Clear all content from database'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showResetDataDialog(context),
      ),
    );
  }

  void _showSeedDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Populate Test Data'),
          content: const Text(
            'This will add 35 sample items (Anime, Comics, Novels, Movies, TV Series) to your library.\n\nExisting data will be cleared. Continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(context);
                _populateTestData(context);
              },
              child: const Text('Populate'),
            ),
          ],
        );
      },
    );
  }

  void _populateTestData(BuildContext context) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Populating database...'),
                ],
              ),
            ),
          ),
        );
      },
    );

    try {
      await SeedData.populate();

      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Test data populated successfully! Check your Library.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                title: const Text('Light'),
                subtitle: const Text('Always use light theme'),
                value: ThemeMode.light,
                groupValue: currentThemeMode,
                onChanged: (ThemeMode? value) {
                  if (value != null) {
                    onThemeChanged(value);
                    Navigator.pop(context);
                  }
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Dark'),
                subtitle: const Text('Always use dark theme'),
                value: ThemeMode.dark,
                groupValue: currentThemeMode,
                onChanged: (ThemeMode? value) {
                  if (value != null) {
                    onThemeChanged(value);
                    Navigator.pop(context);
                  }
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('System'),
                subtitle: const Text('Follow system theme'),
                value: ThemeMode.system,
                groupValue: currentThemeMode,
                onChanged: (ThemeMode? value) {
                  if (value != null) {
                    onThemeChanged(value);
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getThemeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  String _getThemeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  void _showResetDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset All Data'),
          content: const Text(
            'This will permanently delete all content from your database.\n\nThis action cannot be undone. Continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () async {
                Navigator.pop(context);
                _resetData(context);
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  void _resetData(BuildContext context) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Clearing database...'),
                ],
              ),
            ),
          ),
        );
      },
    );

    try {
      final db = DatabaseService();
      final isar = await db.isar;
      await isar.writeTxn(() async {
        await isar.contentItems.clear();
      });

      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ All data has been cleared'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _showImportDialog(BuildContext context) {
    final jsonController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Import List from JSON'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Paste the exported JSON data below:',
                  style: Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: jsonController,
                  maxLines: 10,
                  decoration: InputDecoration(
                    hintText: '{\n  "app": "Content Tracker",\n  "version": "1.0",\n  ...\n}',
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '💡 Tip: Export a list from the Library tab to get the JSON format',
                  style: Theme.of(dialogContext).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                jsonController.dispose();
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final jsonString = jsonController.text.trim();
                jsonController.dispose();
                Navigator.pop(dialogContext);

                if (jsonString.isNotEmpty) {
                  await _importList(context, jsonString);
                }
              },
              child: const Text('Import'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _importList(BuildContext context, String jsonString) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Importing list...'),
                ],
              ),
            ),
          ),
        );
      },
    );

    try {
      // Parse JSON
      final Map<String, dynamic> data = jsonDecode(jsonString);

      // Validate format
      if (data['app'] != 'Content Tracker') {
        throw Exception('Invalid JSON format: not a Content Tracker export');
      }

      final String listName = data['list_name'] ?? 'Imported List';
      final String? listDescription = data['list_description'];
      final String? listIcon = data['list_icon'];
      final List<dynamic> itemsData = data['items'] ?? [];

      final db = DatabaseService();

      // Create the list
      final allLists = await db.getAllLists();
      final newOrder = allLists.isEmpty
          ? 0
          : allLists.map((l) => l.order).reduce((a, b) => a > b ? a : b) + 1;

      final newList = CustomList(
        name: listName,
        description: listDescription,
        icon: listIcon ?? '📚',
        order: newOrder,
      );

      await db.createList(newList);

      // Import content items
      int importedCount = 0;
      int skippedCount = 0;

      for (final itemData in itemsData) {
        try {
          final String title = itemData['title'] ?? 'Untitled';
          final String typeStr = itemData['type'] ?? 'anime';
          final String statusStr = itemData['status'] ?? 'planToWatch';
          final int progress = itemData['progress'] ?? 0;
          final int total = itemData['total'] ?? 0;
          final String? category = itemData['category'];
          final String? notes = itemData['notes'];

          // Parse enums
          ContentType? type;
          try {
            type = ContentType.values.firstWhere(
              (e) => e.toString().split('.').last == typeStr,
            );
          } catch (_) {
            type = ContentType.anime; // Default fallback
          }

          ContentStatus? status;
          try {
            status = ContentStatus.values.firstWhere(
              (e) => e.toString().split('.').last == statusStr,
            );
          } catch (_) {
            status = ContentStatus.planToWatch; // Default fallback
          }

          // Create content item
          final contentItem = ContentItem(
            title: title,
            type: type,
            status: status,
            progress: progress,
            total: total,
            category: category,
            notes: notes,
          );

          await db.addContentItem(contentItem);

          // Add to the new list
          await db.addContentToList(newList.id, contentItem.id);

          importedCount++;
        } catch (e) {
          skippedCount++;
          debugPrint('Error importing item: $e');
        }
      }

      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Imported "$listName" with $importedCount items' +
                  (skippedCount > 0 ? ' ($skippedCount skipped)' : ''),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Import failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}
