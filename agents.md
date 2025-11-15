# Content Tracker - Flutter App v1.0

A modern, offline-first content tracking application for Anime, Comics, Novels, Movies, and TV Series built with Flutter and Material Design 3.

## Features

### Core Functionality
- **Multi-Profile System**: 5 dedicated profiles (Anime, Movies, Novels, TV Series, Comics)
- **Dynamic Theming**: App theme changes based on selected profile color
- **Content Management**: Full CRUD operations for tracking content
- **Status Tracking**: Plan to Watch, Watching, Completed, On Hold, Dropped
- **Progress Tracking**: Track episode/chapter/page progress with visual indicators
- **Offline-First**: Full functionality without internet using Isar database
- **Category/Genre System**: Tag content with multiple comma-separated genres

### Screens
1. **Home**: Currently watching content (list view)
2. **Discover**: Browse plan-to-watch content (grid view, IMDB/MAL style)
3. **Library**: All content organized by status tabs (grid view)
4. **Settings**: Theme toggle, statistics, data management

### UI/UX Highlights
- Material Design 3 with modern typography (better readability, larger fonts)
- Profile badges with switcher modal
- Search and filter icons (prepared for advanced filtering)
- Grid cards with poster-style layouts (2:3 aspect ratio)
- List cards for active content
- Empty states with helpful actions
- Pull-to-refresh on all content lists
- Floating Action Button for quick content addition

### Technical Stack
- **Framework**: Flutter 3.x with Material Design 3
- **Database**: Isar (NoSQL, embedded, offline-first)
- **State Management**: ChangeNotifier (ProfileNotifier)
- **Architecture**:
  - Models with Isar annotations
  - Services layer (DatabaseService)
  - Screens with StatefulWidget
  - Reusable widgets
  - Theme configuration with dynamic colors

### Project Structure
```
lib/
├── main.dart                    # App entry point
├── models/
│   ├── content_item.dart        # Content data model
│   ├── enums.dart              # ContentType, ContentStatus enums
│   └── profile_type.dart       # ProfileType enum & ProfileNotifier
├── screens/
│   ├── home/
│   │   └── home_screen.dart    # Currently watching screen
│   ├── discover/
│   │   ├── discover_screen.dart    # Browse plan-to-watch
│   │   └── add_content_screen.dart # Add new content form
│   ├── library/
│   │   └── library_screen.dart     # All content by status
│   └── settings/
│       ├── settings_screen.dart    # App settings
│       └── stats_screen.dart       # Statistics dashboard
├── services/
│   └── database_service.dart   # Isar database operations
├── theme/
│   └── app_theme.dart          # Material Design 3 theme config
├── widgets/
│   ├── content_card.dart       # List-style content card
│   ├── content_grid_card.dart  # Grid-style poster card
│   ├── main_navigation.dart    # Bottom navigation
│   ├── profile_switcher.dart   # Profile selection modal
│   └── profile_stats_card.dart # Statistics widget
└── scripts/
    └── seed_data.dart          # Test data population
```

## Design Decisions

### Profile System
- Each profile maps to a ContentType with unique color and icon
- ProfileNotifier at app level for reactive theme changes
- No "All" option - always a profile selected (default: Anime)
- Profile changes trigger filter resets

### Content Model
- Single ContentItem model for all types
- Isar auto-increment ID
- Timestamps: createdAt, updatedAt
- Optional fields: imageUrl, notes, category
- Progress tracking with automatic completion

### UI/UX Philosophy
- **Modern Typography**: Larger, more readable text with proper letter spacing
- **Generous Spacing**: Better padding and margins for comfortable viewing
- **Rounded Corners**: 14-16px radius for modern feel
- **Minimal Elevations**: Flat design with subtle shadows
- **Profile Colors**: Visual identity through dynamic theming
- **Consistent Navigation**: Bottom nav with 72px height, 28px icons
- **Categorize Later**: Simple genre tags (comma-separated) instead of complex taxonomy

### Data Organization
- **Home**: "Watching" status only (active content)
- **Discover**: "Plan to Watch" status only (future content)
- **Library**: All statuses with tab navigation

## Performance Optimizations
- Batch database writes for seed data
- Single transaction for data operations
- IndexedStack for tab state preservation
- FutureBuilder with proper loading states
- Efficient Isar queries with filters

## Future Enhancements (Post-v1)
- Advanced filter bottom sheet (multi-select genres, year range, sorting)
- Search implementation
- Multi-genre support (parse comma-separated values)
- Image upload/URL support
- Import/export functionality
- Cloud sync (optional)
- Widgets for home screen
- Recommendations system

## Development Commands

```bash
# Run app
flutter run

# Build for production
flutter build apk --release
flutter build ios --release

# Generate Isar schema (after model changes)
flutter pub run build_runner build --delete-conflicting-outputs

# Populate test data
# Settings → Developer → Populate Test Data

# Reset all data
# Settings → Developer → Reset All Data
```

## Database Schema

### ContentItem
| Field | Type | Description |
|-------|------|-------------|
| id | int | Auto-increment primary key |
| title | String | Content title (required) |
| type | ContentType | Anime/Comic/Novel/Movie/TVSeries |
| status | ContentStatus | Plan/Watching/Completed/OnHold/Dropped |
| progress | int | Current episode/chapter/page |
| total | int | Total episodes/chapters/pages |
| category | String? | Genre tags (comma-separated) |
| imageUrl | String? | Cover/poster image URL |
| notes | String? | User notes |
| createdAt | DateTime | Creation timestamp |
| updatedAt | DateTime | Last update timestamp |

### Enums
- **ContentType**: anime, comic, novel, movie, tvSeries
- **ContentStatus**: planToWatch, watching, completed, onHold, dropped
- **ProfileType**: anime, movies, novels, tvSeries, comics

## Theme Colors

### Profiles
- **Anime**: #2196F3 (Blue)
- **Movies**: #F44336 (Red)
- **Novels**: #4CAF50 (Green)
- **TV Series**: #9C27B0 (Purple)
- **Comics**: #FF9800 (Orange)

### Light Theme
- Background: #FAFAFA
- Surface: #FFFFFF
- Text: #1A1A1A
- Border: #E5E7EB

### Dark Theme
- Background: #0A0A0A
- Surface: #1C1C1E
- Card: #2C2C2E
- Text: #F5F5F5
- Border: #374151

## Contributing

This is a personal project. The codebase follows Flutter best practices and Material Design guidelines.

## License

Private - All rights reserved.

## Version History

### v1.0 (Current)
- Initial release
- Multi-profile system with dynamic theming
- Full CRUD for content management
- Modern Material Design 3 UI
- Offline-first with Isar database
- Statistics dashboard
- Test data seed functionality
