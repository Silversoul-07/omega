import 'package:isar/isar.dart';
import 'enums.dart';

part 'content_item.g.dart';

/// Core data model for tracking content items
@collection
class ContentItem {
  /// Auto-incrementing ID
  Id id = Isar.autoIncrement;

  /// Title of the content
  @Index()
  late String title;

  /// Profile ID (references Profile collection)
  late int profileId;

  /// Category ID (references Category collection)
  late int categoryId;

  /// Current status of the content
  @Enumerated(EnumType.name)
  late ContentStatus status;

  /// Current progress (e.g., episode/chapter number)
  late int progress;

  /// Total episodes/chapters (0 if unknown)
  late int total;

  /// URL or path to the image
  String? imageUrl;

  /// When the item was created
  late DateTime createdAt;

  /// When the item was last updated
  late DateTime updatedAt;

  /// Optional notes
  String? notes;

  /// Constructor
  ContentItem({
    this.id = Isar.autoIncrement,
    required this.title,
    required this.profileId,
    required this.categoryId,
    this.status = ContentStatus.planToWatch,
    this.progress = 0,
    this.total = 0,
    this.imageUrl,
    this.notes,
  }) {
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
  }

  /// Calculate progress percentage
  double get progressPercentage {
    if (total <= 0) return 0.0;
    return (progress / total * 100).clamp(0.0, 100.0);
  }

  /// Check if content is completed
  bool get isCompleted => status == ContentStatus.completed;

  /// Format progress as string (e.g., "24 / 100" or "24 / ?")
  String get progressDisplay {
    if (total > 0) {
      return '$progress / $total';
    }
    return '$progress / ?';
  }
}
