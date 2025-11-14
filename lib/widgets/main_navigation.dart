import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import '../screens/discover/discover_screen.dart';
import '../screens/library/library_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../models/profile_type.dart';

/// Main navigation widget with 4-tab bottom navigation and profile selector
class MainNavigation extends StatefulWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  const MainNavigation({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final ProfileNotifier _profileNotifier = ProfileNotifier()
    ..selectProfile(ProfileType.anime);

  @override
  void dispose() {
    _profileNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _profileNotifier,
      builder: (context, child) {
        final List<Widget> screens = [
          HomeScreen(selectedProfile: _profileNotifier.selectedProfile),
          DiscoverScreen(selectedProfile: _profileNotifier.selectedProfile),
          LibraryScreen(selectedProfile: _profileNotifier.selectedProfile),
          SettingsScreen(
            currentThemeMode: widget.themeMode,
            onThemeChanged: widget.onThemeChanged,
          ),
        ];

        return Scaffold(
          appBar: _currentIndex != 3 ? _buildProfileSelector() : null,
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

  PreferredSizeWidget _buildProfileSelector() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: ProfileType.values.map((profile) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildProfileChip(profile.displayName, profile),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileChip(String label, ProfileType profile) {
    final isSelected = _profileNotifier.selectedProfile == profile;
    final color = profile.color;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            profile.icon,
            size: 16,
            color: isSelected ? color : Colors.grey,
          ),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          _profileNotifier.selectProfile(profile);
        }
      },
      selectedColor: color.withOpacity(0.15),
      checkmarkColor: color,
      labelStyle: TextStyle(
        color: isSelected ? color : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? color : Colors.grey.shade300,
        width: isSelected ? 2 : 1,
      ),
    );
  }
}
