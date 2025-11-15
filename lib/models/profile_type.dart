import 'package:flutter/material.dart';
import 'enums.dart';

/// Profile types representing broad content categories
enum ProfileType {
  anime,
  movies,
  novels,
  tvSeries,
  comics,
}

extension ProfileTypeExtension on ProfileType {
  String get displayName {
    switch (this) {
      case ProfileType.anime:
        return 'Anime';
      case ProfileType.movies:
        return 'Movies';
      case ProfileType.novels:
        return 'Novels';
      case ProfileType.tvSeries:
        return 'TV Series';
      case ProfileType.comics:
        return 'Comics';
    }
  }

  Color get color {
    switch (this) {
      case ProfileType.anime:
        return const Color(0xFF2196F3); // Blue
      case ProfileType.movies:
        return const Color(0xFFF44336); // Red
      case ProfileType.novels:
        return const Color(0xFF4CAF50); // Green
      case ProfileType.tvSeries:
        return const Color(0xFF9C27B0); // Purple
      case ProfileType.comics:
        return const Color(0xFFFF9800); // Orange
    }
  }

  IconData get icon {
    switch (this) {
      case ProfileType.anime:
        return Icons.animation;
      case ProfileType.movies:
        return Icons.movie;
      case ProfileType.novels:
        return Icons.menu_book;
      case ProfileType.tvSeries:
        return Icons.tv;
      case ProfileType.comics:
        return Icons.auto_stories;
    }
  }

  /// Map ProfileType to ContentType for filtering
  ContentType get contentType {
    switch (this) {
      case ProfileType.anime:
        return ContentType.anime;
      case ProfileType.movies:
        return ContentType.movie;
      case ProfileType.novels:
        return ContentType.novel;
      case ProfileType.tvSeries:
        return ContentType.tvSeries;
      case ProfileType.comics:
        return ContentType.comic;
    }
  }
}

/// Simple state management for selected profile
class ProfileNotifier extends ChangeNotifier {
  ProfileType? _selectedProfile;

  ProfileType? get selectedProfile => _selectedProfile;

  void selectProfile(ProfileType? profile) {
    _selectedProfile = profile;
    notifyListeners();
  }

  Color get currentAccentColor {
    return _selectedProfile?.color ?? const Color(0xFF6366F1);
  }
}
