/// Content type enum for different media types
enum ContentType {
  anime,
  comic,
  novel,
  movie,
  tvSeries,
}

/// Status enum for tracking progress
enum ContentStatus {
  planToWatch,
  watching,
  completed,
  onHold,
  dropped,
}

/// Extension to get display names for ContentType
extension ContentTypeExtension on ContentType {
  String get displayName {
    switch (this) {
      case ContentType.anime:
        return 'Anime';
      case ContentType.comic:
        return 'Comic';
      case ContentType.novel:
        return 'Novel';
      case ContentType.movie:
        return 'Movie';
      case ContentType.tvSeries:
        return 'TV Series';
    }
  }
}

/// Extension to get display names for ContentStatus
extension ContentStatusExtension on ContentStatus {
  String get displayName {
    switch (this) {
      case ContentStatus.planToWatch:
        return 'Plan to Watch';
      case ContentStatus.watching:
        return 'Watching';
      case ContentStatus.completed:
        return 'Completed';
      case ContentStatus.onHold:
        return 'On Hold';
      case ContentStatus.dropped:
        return 'Dropped';
    }
  }
}
