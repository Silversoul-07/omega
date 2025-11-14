import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/content_item.dart';
import '../models/enums.dart';

/// Service to manage Isar database operations
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Isar? _isar;

  /// Get the Isar instance
  Future<Isar> get isar async {
    if (_isar != null && _isar!.isOpen) {
      return _isar!;
    }
    _isar = await _initIsar();
    return _isar!;
  }

  /// Initialize the Isar database
  Future<Isar> _initIsar() async {
    final dir = await getApplicationDocumentsDirectory();
    return await Isar.open(
      [ContentItemSchema],
      directory: dir.path,
      inspector: true, // Enable Isar Inspector for debugging
    );
  }

  /// Get all content items
  Future<List<ContentItem>> getAllContentItems() async {
    final db = await isar;
    return await db.contentItems.where().findAll();
  }

  /// Get content items by type
  Future<List<ContentItem>> getContentItemsByType(ContentType type) async {
    final db = await isar;
    return await db.contentItems.filter().typeEqualTo(type).findAll();
  }

  /// Get content items by status
  Future<List<ContentItem>> getContentItemsByStatus(ContentStatus status) async {
    final db = await isar;
    return await db.contentItems.filter().statusEqualTo(status).findAll();
  }

  /// Get content items by type and status
  Future<List<ContentItem>> getContentItemsByTypeAndStatus(
    ContentType type,
    ContentStatus status,
  ) async {
    final db = await isar;
    return await db.contentItems
        .filter()
        .typeEqualTo(type)
        .and()
        .statusEqualTo(status)
        .findAll();
  }

  /// Add a new content item
  Future<void> addContentItem(ContentItem item) async {
    final db = await isar;
    await db.writeTxn(() async {
      await db.contentItems.put(item);
    });
  }

  /// Update an existing content item
  Future<void> updateContentItem(ContentItem item) async {
    final db = await isar;
    item.updatedAt = DateTime.now();
    await db.writeTxn(() async {
      await db.contentItems.put(item);
    });
  }

  /// Delete a content item
  Future<void> deleteContentItem(int id) async {
    final db = await isar;
    await db.writeTxn(() async {
      await db.contentItems.delete(id);
    });
  }

  /// Update progress for a content item
  Future<void> updateProgress(int id, int newProgress) async {
    final db = await isar;
    await db.writeTxn() async {
      final item = await db.contentItems.get(id);
      if (item != null) {
        item.progress = newProgress;
        item.updatedAt = DateTime.now();

        // Auto-complete if progress reaches total
        if (item.total > 0 && item.progress >= item.total) {
          item.status = ContentStatus.completed;
        }

        await db.contentItems.put(item);
      }
    });
  }

  /// Search content items by title
  Future<List<ContentItem>> searchByTitle(String query) async {
    final db = await isar;
    return await db.contentItems
        .filter()
        .titleContains(query, caseSensitive: false)
        .findAll();
  }

  /// Close the database
  Future<void> close() async {
    await _isar?.close();
  }
}
