import 'package:flutter/material.dart';
import '../models/content_item.dart';
import '../models/enums.dart';
import '../services/database_service.dart';

/// Seed script to populate the database with sample data for testing
class SeedData {
  static Future<void> populate() async {
    final db = DatabaseService();

    // Clear existing data (optional - comment out if you want to keep existing data)
    final existing = await db.getAllContentItems();
    for (final item in existing) {
      await db.deleteContentItem(item.id);
    }

    print('🌱 Starting database seeding...');

    // Anime - Currently Watching
    await db.addContentItem(ContentItem(
      title: 'Attack on Titan',
      type: ContentType.anime,
      status: ContentStatus.watching,
      progress: 24,
      total: 87,
      imageUrl: 'https://cdn.myanimelist.net/images/anime/10/47347.jpg',
      notes: 'Epic story about humanity fighting titans. Currently at Season 2.',
    ));

    await db.addContentItem(ContentItem(
      title: 'Demon Slayer',
      type: ContentType.anime,
      status: ContentStatus.watching,
      progress: 45,
      total: 63,
      imageUrl: 'https://cdn.myanimelist.net/images/anime/1286/99889.jpg',
      notes: 'Amazing animation and fighting scenes!',
    ));

    await db.addContentItem(ContentItem(
      title: 'One Piece',
      type: ContentType.anime,
      status: ContentStatus.watching,
      progress: 850,
      total: 1100,
      imageUrl: 'https://cdn.myanimelist.net/images/anime/6/73245.jpg',
      notes: 'The legendary pirate adventure continues!',
    ));

    // Anime - Completed
    await db.addContentItem(ContentItem(
      title: 'Fullmetal Alchemist: Brotherhood',
      type: ContentType.anime,
      status: ContentStatus.completed,
      progress: 64,
      total: 64,
      imageUrl: 'https://cdn.myanimelist.net/images/anime/1223/96541.jpg',
      notes: '10/10 masterpiece. One of the best anime ever made.',
    ));

    await db.addContentItem(ContentItem(
      title: 'Death Note',
      type: ContentType.anime,
      status: ContentStatus.completed,
      progress: 37,
      total: 37,
      imageUrl: 'https://cdn.myanimelist.net/images/anime/9/9453.jpg',
      notes: 'Brilliant psychological thriller.',
    ));

    // Anime - Plan to Watch
    await db.addContentItem(ContentItem(
      title: 'Steins;Gate',
      type: ContentType.anime,
      status: ContentStatus.planToWatch,
      progress: 0,
      total: 24,
      imageUrl: 'https://cdn.myanimelist.net/images/anime/5/73199.jpg',
      notes: 'Heard great things about the time travel story.',
    ));

    await db.addContentItem(ContentItem(
      title: 'Cowboy Bebop',
      type: ContentType.anime,
      status: ContentStatus.planToWatch,
      progress: 0,
      total: 26,
      imageUrl: 'https://cdn.myanimelist.net/images/anime/4/19644.jpg',
      notes: 'Classic anime on my watchlist.',
    ));

    // Anime - On Hold
    await db.addContentItem(ContentItem(
      title: 'Hunter x Hunter',
      type: ContentType.anime,
      status: ContentStatus.onHold,
      progress: 30,
      total: 148,
      imageUrl: 'https://cdn.myanimelist.net/images/anime/11/33657.jpg',
      notes: 'Taking a break. Will continue later.',
    ));

    // Comics - Currently Reading
    await db.addContentItem(ContentItem(
      title: 'The Amazing Spider-Man',
      type: ContentType.comic,
      status: ContentStatus.watching,
      progress: 45,
      total: 100,
      imageUrl: 'https://i.annihil.us/u/prod/marvel/i/mg/3/50/526548a343e4b.jpg',
      notes: 'Following the latest run. Great storyline!',
    ));

    await db.addContentItem(ContentItem(
      title: 'Batman: The Long Halloween',
      type: ContentType.comic,
      status: ContentStatus.watching,
      progress: 8,
      total: 13,
      imageUrl: 'https://m.media-amazon.com/images/I/91WvnJKxvuL.jpg',
      notes: 'Classic Batman mystery story.',
    ));

    // Comics - Completed
    await db.addContentItem(ContentItem(
      title: 'Watchmen',
      type: ContentType.comic,
      status: ContentStatus.completed,
      progress: 12,
      total: 12,
      imageUrl: 'https://m.media-amazon.com/images/I/71qxG7nwurl.jpg',
      notes: 'Masterpiece of the comic medium.',
    ));

    // Comics - Plan to Read
    await db.addContentItem(ContentItem(
      title: 'Saga',
      type: ContentType.comic,
      status: ContentStatus.planToWatch,
      progress: 0,
      total: 54,
      imageUrl: 'https://m.media-amazon.com/images/I/91ZvKvVUsuL.jpg',
      notes: 'Highly recommended space opera.',
    ));

    // Novels - Currently Reading
    await db.addContentItem(ContentItem(
      title: 'The Lord of the Rings',
      type: ContentType.novel,
      status: ContentStatus.watching,
      progress: 2,
      total: 3,
      imageUrl: 'https://m.media-amazon.com/images/I/7125+5E40JL.jpg',
      notes: 'Reading The Two Towers now. Epic fantasy!',
    ));

    await db.addContentItem(ContentItem(
      title: 'Dune',
      type: ContentType.novel,
      status: ContentStatus.watching,
      progress: 1,
      total: 6,
      imageUrl: 'https://m.media-amazon.com/images/I/81ym3zu0E3L.jpg',
      notes: 'Started the series. Fascinating world-building.',
    ));

    // Novels - Completed
    await db.addContentItem(ContentItem(
      title: 'Harry Potter Series',
      type: ContentType.novel,
      status: ContentStatus.completed,
      progress: 7,
      total: 7,
      imageUrl: 'https://m.media-amazon.com/images/I/81YOuOGFCJL.jpg',
      notes: 'Finished all books. Loved the entire journey!',
    ));

    await db.addContentItem(ContentItem(
      title: '1984',
      type: ContentType.novel,
      status: ContentStatus.completed,
      progress: 1,
      total: 1,
      imageUrl: 'https://m.media-amazon.com/images/I/71kxa1-0mfL.jpg',
      notes: 'Dystopian classic. Very relevant today.',
    ));

    // Novels - Plan to Read
    await db.addContentItem(ContentItem(
      title: 'The Name of the Wind',
      type: ContentType.novel,
      status: ContentStatus.planToWatch,
      progress: 0,
      total: 3,
      imageUrl: 'https://m.media-amazon.com/images/I/91b8oN-CQ5L.jpg',
      notes: 'Part of The Kingkiller Chronicle. Waiting to start.',
    ));

    // Movies - Completed
    await db.addContentItem(ContentItem(
      title: 'The Shawshank Redemption',
      type: ContentType.movie,
      status: ContentStatus.completed,
      progress: 1,
      total: 1,
      imageUrl: 'https://m.media-amazon.com/images/I/51NiGlapXlL.jpg',
      notes: 'One of the greatest movies of all time. 10/10',
    ));

    await db.addContentItem(ContentItem(
      title: 'Inception',
      type: ContentType.movie,
      status: ContentStatus.completed,
      progress: 1,
      total: 1,
      imageUrl: 'https://m.media-amazon.com/images/I/81p+xe8cbnL.jpg',
      notes: 'Mind-bending masterpiece by Christopher Nolan.',
    ));

    await db.addContentItem(ContentItem(
      title: 'Spirited Away',
      type: ContentType.movie,
      status: ContentStatus.completed,
      progress: 1,
      total: 1,
      imageUrl: 'https://m.media-amazon.com/images/I/51JtXElectoral2L.jpg',
      notes: 'Beautiful Studio Ghibli film. Enchanting!',
    ));

    // Movies - Plan to Watch
    await db.addContentItem(ContentItem(
      title: 'The Godfather',
      type: ContentType.movie,
      status: ContentStatus.planToWatch,
      progress: 0,
      total: 1,
      imageUrl: 'https://m.media-amazon.com/images/I/41+AoOLssmL.jpg',
      notes: 'Classic that I need to finally watch.',
    ));

    await db.addContentItem(ContentItem(
      title: 'Interstellar',
      type: ContentType.movie,
      status: ContentStatus.planToWatch,
      progress: 0,
      total: 1,
      imageUrl: 'https://m.media-amazon.com/images/I/91obuWzA3XL.jpg',
      notes: 'Another Nolan film on my list.',
    ));

    // TV Series - Currently Watching
    await db.addContentItem(ContentItem(
      title: 'Breaking Bad',
      type: ContentType.tvSeries,
      status: ContentStatus.watching,
      progress: 35,
      total: 62,
      imageUrl: 'https://m.media-amazon.com/images/I/81I8T0MxsZL.jpg',
      notes: 'Halfway through. Absolutely gripping!',
    ));

    await db.addContentItem(ContentItem(
      title: 'The Last of Us',
      type: ContentType.tvSeries,
      status: ContentStatus.watching,
      progress: 5,
      total: 9,
      imageUrl: 'https://m.media-amazon.com/images/I/81bPtHnc9PL.jpg',
      notes: 'Great adaptation of the video game.',
    ));

    await db.addContentItem(ContentItem(
      title: 'Stranger Things',
      type: ContentType.tvSeries,
      status: ContentStatus.watching,
      progress: 25,
      total: 42,
      imageUrl: 'https://m.media-amazon.com/images/I/91e8K3qj4IL.jpg',
      notes: 'Waiting for the next season!',
    ));

    // TV Series - Completed
    await db.addContentItem(ContentItem(
      title: 'Game of Thrones',
      type: ContentType.tvSeries,
      status: ContentStatus.completed,
      progress: 73,
      total: 73,
      imageUrl: 'https://m.media-amazon.com/images/I/91DL7P9GttL.jpg',
      notes: 'Epic journey. Controversial ending though.',
    ));

    await db.addContentItem(ContentItem(
      title: 'The Office',
      type: ContentType.tvSeries,
      status: ContentStatus.completed,
      progress: 201,
      total: 201,
      imageUrl: 'https://m.media-amazon.com/images/I/71+FKWPxjNL.jpg',
      notes: 'Comfort show. Can rewatch anytime!',
    ));

    // TV Series - Plan to Watch
    await db.addContentItem(ContentItem(
      title: 'The Wire',
      type: ContentType.tvSeries,
      status: ContentStatus.planToWatch,
      progress: 0,
      total: 60,
      imageUrl: 'https://m.media-amazon.com/images/I/71aJPHKHG9L.jpg',
      notes: 'Heard it\'s one of the best shows ever made.',
    ));

    await db.addContentItem(ContentItem(
      title: 'Better Call Saul',
      type: ContentType.tvSeries,
      status: ContentStatus.planToWatch,
      progress: 0,
      total: 63,
      imageUrl: 'https://m.media-amazon.com/images/I/81LWFbLu1yL.jpg',
      notes: 'Breaking Bad spinoff. Must watch!',
    ));

    // TV Series - On Hold
    await db.addContentItem(ContentItem(
      title: 'Westworld',
      type: ContentType.tvSeries,
      status: ContentStatus.onHold,
      progress: 18,
      total: 36,
      imageUrl: 'https://m.media-amazon.com/images/I/91RfD8jPrqL.jpg',
      notes: 'Took a break after season 2. Will resume later.',
    ));

    // TV Series - Dropped
    await db.addContentItem(ContentItem(
      title: 'Lost',
      type: ContentType.tvSeries,
      status: ContentStatus.dropped,
      progress: 12,
      total: 121,
      imageUrl: 'https://m.media-amazon.com/images/I/91WKLawkKQL.jpg',
      notes: 'Couldn\'t get into it. Maybe I\'ll try again someday.',
    ));

    print('✅ Database seeded successfully with 35 items!');
    print('');
    print('Summary:');
    print('- Anime: 8 items');
    print('- Comics: 4 items');
    print('- Novels: 5 items');
    print('- Movies: 5 items');
    print('- TV Series: 8 items');
    print('');
    print('Status distribution:');
    print('- Currently Watching/Reading: 12 items');
    print('- Completed: 11 items');
    print('- Plan to Watch/Read: 9 items');
    print('- On Hold: 2 items');
    print('- Dropped: 1 item');
  }
}
