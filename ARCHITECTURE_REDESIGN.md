# Architecture Redesign - Profile-Based System

## Overview
Complete redesign of the content tracking app to use a Profile-based architecture with categories and dynamic theming.

## Current Progress

### ✅ Completed

1. **Data Models Created:**
   - `Profile` model (lib/models/profile.dart) - Represents broad categories (Anime, Movies, etc.) with custom colors
   - `Category` model (lib/models/category.dart) - Subcategories within profiles (Japanese Anime, Hollywood, etc.)
   - Updated `ContentItem` model to use `profileId` and `categoryId` instead of simple `type`

2. **Database Service Updated:**
   - Added Profile and Category CRUD operations
   - Auto-initialization of default profiles and categories:
     - **Anime** (Blue): Japanese Anime, Western Cartoon, Donghua
     - **Movies** (Red): Hollywood, Bollywood, Other
     - **Novels** (Green): YA Novel, Web Novel, Eastern, Western, Indian
     - **TV Series** (Purple): Western, Chinese Drama, Korean Drama, Japanese Drama
     - **Comics** (Orange): Western Comics, Manga, Manhua, Manhwa
   - Enhanced query methods for filtering by profile, category, and status

### 🔨 Next Steps Required

1. **Generate Isar Schemas:**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
   This MUST be run to generate:
   - `lib/models/profile.g.dart`
   - `lib/models/category.g.dart`
   - Updated `lib/models/content_item.g.dart`

2. **Create Profile State Management:**
   - ProfileProvider using Provider package
   - Manages currently selected profile
   - Notifies UI when profile changes

3. **Update Theme System:**
   - Soft white background for light mode
   - Pure black for dark mode
   - Dynamic accent colors based on selected profile

4. **Update All Screens:**
   - **Home Screen**: List view with category tag filtering
   - **Discover Screen**: Card view with profile filtering
   - **Library Screen**: Card view with profile-based tabs
   - **Navigation**: Add profile selector (horizontal scrollable chips)

5. **Create Profile Management UI:**
   - Settings screen for creating/editing profiles
   - Manage categories per profile
   - Custom color picker
   - Add/remove categories with + button

6. **Update Seed Data:**
   - Migrate test data to use new profile/category system
   - Assign proper profileId and categoryId to each content item

## Architecture Design

### Profile System
```
Profile (Broad Category)
  ├── Color Theme
  ├── Icon
  └── Categories (Subcategories)
        ├── Japanese Anime
        ├── Western Cartoon
        └── Donghua
```

### User Workflow
1. Select Profile (Anime, Movies, etc.) → Changes theme color
2. View filtered content (Home shows only "watching" items from selected profile)
3. Filter by Category tags (Japanese Anime, Donghua, etc.)
4. Search/Discover within selected profile
5. Library shows all content organized by status, filtered by profile

### UI Layout Changes
- **Home**: List view with compact cards, horizontal category chips
- **Discover**: Grid/card view for browsing
- **Library**: Tabbed interface (All, Completed, Plan to Watch, On Hold, Dropped) with cards

## Database Schema

### Profile Table
| Field | Type | Description |
|-------|------|-------------|
| id | int | Auto-increment |
| name | String | Profile name (e.g., "Anime") |
| colorValue | int | Flutter Color.value |
| icon | String | Material icon name |
| order | int | Display order |
| createdAt | DateTime | Creation timestamp |

### Category Table
| Field | Type | Description |
|-------|------|-------------|
| id | int | Auto-increment |
| profileId | int | Foreign key to Profile |
| name | String | Category name |
| order | int | Display order |
| createdAt | DateTime | Creation timestamp |

### ContentItem Table (Updated)
| Field | Type | Description |
|-------|------|-------------|
| id | int | Auto-increment |
| title | String | Content title |
| profileId | int | Foreign key to Profile |
| categoryId | int | Foreign key to Category |
| status | enum | watching/completed/planToWatch/onHold/dropped |
| progress | int | Current episode/chapter |
| total | int | Total episodes/chapters |
| imageUrl | String? | Cover image |
| notes | String? | User notes |
| createdAt | DateTime | Creation timestamp |
| updatedAt | DateTime | Last update timestamp |

## Color Scheme

### Default Profile Colors
- Anime: Blue (#2196F3)
- Movies: Red (#F44336)
- Novels: Green (#4CAF50)
- TV Series: Purple (#9C27B0)
- Comics: Orange (#FF9800)

### Theme Colors
- Light Mode: Soft white background (#F5F5F5)
- Dark Mode: Pure black (#000000)
- Accent: Dynamic based on selected profile
- Surface cards: Slightly elevated from background

## Migration Notes

**BREAKING CHANGES:**
- ContentItem no longer uses `ContentType` enum
- Now uses `profileId` and `categoryId` integers
- Existing data will need migration or re-seeding
- All UI components must be updated to work with new schema

## Implementation Priority

1. [CRITICAL] Generate Isar schemas
2. [CRITICAL] Create ProfileProvider
3. [HIGH] Update seed data script
4. [HIGH] Update Home screen with list view
5. [MEDIUM] Update Discover screen
6. [MEDIUM] Update Library screen
7. [MEDIUM] Add profile selector to navigation
8. [LOW] Create profile management UI
9. [LOW] Implement theme switching

## Testing Checklist

- [ ] Database initializes with default profiles/categories
- [ ] Can select different profiles
- [ ] Theme color changes with profile selection
- [ ] Home screen shows only watching items from selected profile
- [ ] Category filtering works on Home screen
- [ ] Discover shows all items from selected profile
- [ ] Library tabs work with profile filtering
- [ ] Can create new profiles in settings
- [ ] Can add/edit/delete categories
- [ ] Seed data populates correctly with new schema
