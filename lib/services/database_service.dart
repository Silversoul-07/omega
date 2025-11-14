import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/content_item.dart';
import '../models/profile.dart';
import '../models/category.dart';
import '../models/enums.dart';
import 'package:flutter/material.dart';

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
    final isar = await Isar.open(
      [ContentItemSchema, ProfileSchema, CategorySchema],
      directory: dir.path,
      inspector: true,
    );

    // Initialize default profiles and categories if needed
    await _initializeDefaultData(isar);

    return isar;
  }

  /// Initialize default profiles and categories
  Future<void> _initializeDefaultData(Isar isar) async {
    final profileCount = await isar.profiles.count();
    if (profileCount > 0) return; // Already initialized

    await isar.writeTxn(() async {
      // Create default profiles
      final animeProfile = Profile.create(
        name: 'Anime',
        colorValue: Colors.blue.value,
        icon: 'animation',
        order: 1,
      );
      final animeId = await isar.profiles.put(animeProfile);

      final moviesProfile = Profile.create(
        name: 'Movies',
        colorValue: Colors.red.value,
        icon: 'movie',
        order: 2,
      );
      final moviesId = await isar.profiles.put(moviesProfile);

      final novelsProfile = Profile.create(
        name: 'Novels',
        colorValue: Colors.green.value,
        icon: 'menu_book',
        order: 3,
      );
      final novelsId = await isar.profiles.put(novelsProfile);

      final tvSeriesProfile = Profile.create(
        name: 'TV Series',
        colorValue: Colors.purple.value,
        icon: 'tv',
        order: 4,
      );
      final tvSeriesId = await isar.profiles.put(tvSeriesProfile);

      final comicsProfile = Profile.create(
        name: 'Comics',
        colorValue: Colors.orange.value,
        icon: 'auto_stories',
        order: 5,
      );
      final comicsId = await isar.profiles.put(comicsProfile);

      // Create default categories for Anime
      await isar.categories.putAll([
        Category.create(profileId: animeId, name: 'Japanese Anime', order: 1),
        Category.create(profileId: animeId, name: 'Western Cartoon', order: 2),
        Category.create(profileId: animeId, name: 'Donghua (Chinese)', order: 3),
      ]);

      // Create default categories for Movies
      await isar.categories.putAll([
        Category.create(profileId: moviesId, name: 'Hollywood', order: 1),
        Category.create(profileId: moviesId, name: 'Bollywood', order: 2),
        Category.create(profileId: moviesId, name: 'Other', order: 3),
      ]);

      // Create default categories for Novels
      await isar.categories.putAll([
        Category.create(profileId: novelsId, name: 'YA Novel', order: 1),
        Category.create(profileId: novelsId, name: 'Web Novel', order: 2),
        Category.create(profileId: novelsId, name: 'Eastern', order: 3),
        Category.create(profileId: novelsId, name: 'Western', order: 4),
        Category.create(profileId: novelsId, name: 'Indian', order: 5),
      ]);

      // Create default categories for TV Series
      await isar.categories.putAll([
        Category.create(profileId: tvSeriesId, name: 'Western', order: 1),
        Category.create(profileId: tvSeriesId, name: 'Chinese Drama', order: 2),
        Category.create(profileId: tvSeriesId, name: 'Korean Drama', order: 3),
        Category.create(profileId: tvSeriesId, name: 'Japanese Drama', order: 4),
      ]);

      // Create default categories for Comics
      await isar.categories.putAll([
        Category.create(profileId: comicsId, name: 'Western Comics', order: 1),
        Category.create(profileId: comicsId, name: 'Manga (Japanese)', order: 2),
        Category.create(profileId: comicsId, name: 'Manhua (Chinese)', order: 3),
        Category.create(profileId: comicsId, name: 'Manhwa (Korean)', order: 4),
      ]);
    });
  }

  // ===== Profile Operations =====

  Future<List<Profile>> getAllProfiles() async {
    final db = await isar;
    return await db.profiles.where().sortByOrder().findAll();
  }

  Future<Profile?> getProfile(int id) async {
    final db = await isar;
    return await db.profiles.get(id);
  }

  Future<void> addProfile(Profile profile) async {
    final db = await isar;
    await db.writeTxn(() async {
      await db.profiles.put(profile);
    });
  }

  Future<void> updateProfile(Profile profile) async {
    final db = await isar;
    await db.writeTxn(() async {
      await db.profiles.put(profile);
    });
  }

  Future<void> deleteProfile(int id) async {
    final db = await isar;
    await db.writeTxn(() async {
      await db.profiles.delete(id);
    });
  }

  // ===== Category Operations =====

  Future<List<Category>> getCategoriesByProfile(int profileId) async {
    final db = await isar;
    return await db.categories
        .filter()
        .profileIdEqualTo(profileId)
        .sortByOrder()
        .findAll();
  }

  Future<Category?> getCategory(int id) async {
    final db = await isar;
    return await db.categories.get(id);
  }

  Future<void> addCategory(Category category) async {
    final db = await isar;
    await db.writeTxn(() async {
      await db.categories.put(category);
    });
  }

  Future<void> updateCategory(Category category) async {
    final db = await isar;
    await db.writeTxn(() async {
      await db.categories.put(category);
    });
  }

  Future<void> deleteCategory(int id) async {
    final db = await isar;
    await db.writeTxn(() async {
      await db.categories.delete(id);
    });
  }

  // ===== Content Item Operations =====

  Future<List<ContentItem>> getAllContentItems() async {
    final db = await isar;
    return await db.contentItems.where().findAll();
  }

  Future<List<ContentItem>> getContentItemsByProfile(int profileId) async {
    final db = await isar;
    return await db.contentItems.filter().profileIdEqualTo(profileId).findAll();
  }

  Future<List<ContentItem>> getContentItemsByCategory(int categoryId) async {
    final db = await isar;
    return await db.contentItems.filter().categoryIdEqualTo(categoryId).findAll();
  }

  Future<List<ContentItem>> getContentItemsByStatus(ContentStatus status) async {
    final db = await isar;
    return await db.contentItems.filter().statusEqualTo(status).findAll();
  }

  Future<List<ContentItem>> getContentItemsByProfileAndStatus(
    int profileId,
    ContentStatus status,
  ) async {
    final db = await isar;
    return await db.contentItems
        .filter()
        .profileIdEqualTo(profileId)
        .and()
        .statusEqualTo(status)
        .findAll();
  }

  Future<List<ContentItem>> getContentItemsByProfileCategoryAndStatus(
    int profileId,
    int? categoryId,
    ContentStatus status,
  ) async {
    final db = await isar;
    if (categoryId == null) {
      return await getContentItemsByProfileAndStatus(profileId, status);
    }
    return await db.contentItems
        .filter()
        .profileIdEqualTo(profileId)
        .and()
        .categoryIdEqualTo(categoryId)
        .and()
        .statusEqualTo(status)
        .findAll();
  }

  Future<void> addContentItem(ContentItem item) async {
    final db = await isar;
    await db.writeTxn(() async {
      await db.contentItems.put(item);
    });
  }

  Future<void> updateContentItem(ContentItem item) async {
    final db = await isar;
    item.updatedAt = DateTime.now();
    await db.writeTxn(() async {
      await db.contentItems.put(item);
    });
  }

  Future<void> deleteContentItem(int id) async {
    final db = await isar;
    await db.writeTxn(() async {
      await db.contentItems.delete(id);
    });
  }

  Future<List<ContentItem>> searchByTitle(String query, {int? profileId}) async {
    final db = await isar;
    if (profileId != null) {
      return await db.contentItems
          .filter()
          .profileIdEqualTo(profileId)
          .and()
          .titleContains(query, caseSensitive: false)
          .findAll();
    }
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
