import 'package:isar/isar.dart';

part 'custom_list.g.dart';

/// Custom list for organizing content
@collection
class CustomList {
  /// Auto-incrementing ID
  Id id = Isar.autoIncrement;

  /// Name of the list
  @Index()
  late String name;

  /// Optional description
  String? description;

  /// List of content item IDs in this list
  late List<int> contentIds;

  /// Optional emoji or icon name
  String? icon;

  /// Order for custom sorting
  late int order;

  /// When the list was created
  late DateTime createdAt;

  /// When the list was last updated
  late DateTime updatedAt;

  /// Whether this is a system list (cannot be deleted)
  late bool isSystem;

  /// Constructor
  CustomList({
    this.id = Isar.autoIncrement,
    required this.name,
    this.description,
    List<int>? contentIds,
    this.icon,
    int? order,
    bool? isSystem,
  }) {
    this.contentIds = contentIds ?? [];
    this.order = order ?? 0;
    this.isSystem = isSystem ?? false;
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
  }

  /// Get number of items in this list
  int get itemCount => contentIds.length;

  /// Check if list contains a specific content item
  bool contains(int contentId) => contentIds.contains(contentId);

  /// Add content item to list
  void addContent(int contentId) {
    if (!contentIds.contains(contentId)) {
      contentIds.add(contentId);
      updatedAt = DateTime.now();
    }
  }

  /// Remove content item from list
  void removeContent(int contentId) {
    contentIds.remove(contentId);
    updatedAt = DateTime.now();
  }

  /// Toggle content item in list
  void toggleContent(int contentId) {
    if (contentIds.contains(contentId)) {
      removeContent(contentId);
    } else {
      addContent(contentId);
    }
  }
}
