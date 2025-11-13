import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'widgets/main_navigation.dart';
import 'services/database_service.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the database
  await DatabaseService().isar;

  runApp(const ContentTrackerApp());
}

class ContentTrackerApp extends StatefulWidget {
  const ContentTrackerApp({super.key});

  @override
  State<ContentTrackerApp> createState() => _ContentTrackerAppState();
}

class _ContentTrackerAppState extends State<ContentTrackerApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _updateThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Content Tracker',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
      home: MainNavigation(
        themeMode: _themeMode,
        onThemeChanged: _updateThemeMode,
      ),
    );
  }
}
