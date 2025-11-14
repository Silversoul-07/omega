import 'package:isar/isar.dart';

part 'category.g.dart';

/// Category represents subcategories within a Profile
/// e.g., For Anime: "Japanese Anime", "Western Cartoon", "Donghua"
@collection
class Category {
  Id id = Isar.autoIncrement;

  late int profileId; // Foreign key to Profile

  @Index()
  late String name; // e.g., "Japanese Anime", "Hollywood", "YA Novel"

  late int order; // Display order within profile

  DateTime createdAt = DateTime.now();

  Category();

  Category.create({
    required this.profileId,
    required this.name,
    required this.order,
  });
}
