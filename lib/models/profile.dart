import 'package:isar/isar.dart';

part 'profile.g.dart';

/// Profile represents a broad content category (Anime, Movies, Novels, etc.)
@collection
class Profile {
  Id id = Isar.autoIncrement;

  @Index()
  late String name; // e.g., "Anime", "Movies", "Novels", "TV Series", "Comics"

  late int colorValue; // Color value for theme

  late String icon; // Icon name for display

  late int order; // Display order

  DateTime createdAt = DateTime.now();

  Profile();

  Profile.create({
    required this.name,
    required this.colorValue,
    required this.icon,
    required this.order,
  });
}
