import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import '../screens/discover/discover_screen.dart';
import '../screens/library/library_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../models/profile_type.dart';

/// Main navigation widget with 4-tab bottom navigation
class MainNavigation extends StatefulWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ProfileNotifier profileNotifier;

  const MainNavigation({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
    required this.profileNotifier,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.profileNotifier,
      builder: (context, child) {
        final List<Widget> screens = [
          HomeScreen(
            selectedProfile: widget.profileNotifier.selectedProfile,
            onProfileChange: (profile) => widget.profileNotifier.selectProfile(profile),
          ),
          DiscoverScreen(
            selectedProfile: widget.profileNotifier.selectedProfile,
            onProfileChange: (profile) => widget.profileNotifier.selectProfile(profile),
          ),
          LibraryScreen(
            selectedProfile: widget.profileNotifier.selectedProfile,
            onProfileChange: (profile) => widget.profileNotifier.selectProfile(profile),
          ),
          SettingsScreen(
            currentThemeMode: widget.themeMode,
            onThemeChanged: widget.onThemeChanged,
            selectedProfile: widget.profileNotifier.selectedProfile,
          ),
        ];

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _currentIndex = index;
              });
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.explore_outlined),
                selectedIcon: Icon(Icons.explore),
                label: 'Discover',
              ),
              NavigationDestination(
                icon: Icon(Icons.library_books_outlined),
                selectedIcon: Icon(Icons.library_books),
                label: 'Library',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        );
      },
    );
  }
}
