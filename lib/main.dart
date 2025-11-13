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

class ContentTrackerApp extends StatelessWidget {
  const ContentTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Content Tracker',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const MainNavigation(),
    );
  }
}
