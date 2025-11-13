# Project: Content Tracker

This file outlines the plan and technical guidelines for building an offline-first content tracking mobile application using Flutter.

## High-Level Vision

- **Offline-First:** All user data is stored locally on the device. No online account is required.
- **Content Types:** The app will track various media types including Anime, Comics, Novels, Movies, and TV Series. These are referred to as "Profiles".
- **Core Features:** Users can add content they are consuming, track their progress (e.g., episode/chapter number), and discover items within their own library.
- **Future Goals:** Implement a backup and restore feature using the user's Google Drive.

## Technical Guidelines

- **Framework:** Flutter
- **Database:** Isar (A fast, easy-to-use, and strongly-typed database for Flutter).
- **State Management:** To be decided (will start with a simple approach).
- **Folder Structure:** Feature-first or layer-first (to be decided).

---

## Development To-Do List

### Phase 1: Project Setup & Core Models

- [ ] Initialize a new Flutter project named `content_tracker`.
- [ ] Set up the Isar database.
- [ ] Define the core data models for Isar:
    - `ContentItem`: A base class/schema with fields like `id`, `title`, `type` (enum: Anime, Comic, etc.), `status` (enum: Watching, Completed, etc.), `progress`, `total`, `imageUrl`.
- [ ] Create a clean, scalable folder structure.

### Phase 2: Main Navigation & UI Shell

- [ ] Implement the main 3-tab navigation bar: Home, Discover, Library.
- [ ] Create placeholder pages for each tab.
- [ ] Set up a basic app theme (colors, fonts).

### Phase 3: Home Tab ("Currently Watching")

- [ ] Implement the "Profile" switcher dropdown at the top of the Home screen.
- [ ] Add a (currently non-functional) search bar.
- [ ] Add filter tags (e.g., "All", "Watching", "Completed").
- [ ] Create a `ListView` to display content items from the database that match the selected profile and filters.
- [ ] Design the list item widget to include:
    - Title and image.
    - A tag for the content type.
    - Increment/decrement buttons for the `progress` field.
    - Display for progress (e.g., "24 / 100").

### Phase 4: Adding & Discovering Content

- [ ] Design the "Discover" page UI:
    - Search bar.
    - Filter tags.
    - `GridView` with card-style widgets for content.
- [ ] Create a form or screen to manually add a new `ContentItem` to the database. This will likely be accessed via a floating action button on the Discover or Home page.
- [ ] Connect the Discover page to the database to show all items of the selected profile.

### Phase 5: Library Tab

- [ ] Plan and design the Library tab (details to be decided later).
