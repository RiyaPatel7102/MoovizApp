# MovieApp - Flutter Movies Application

A comprehensive Flutter movie application that uses The Movie Database (TMDB) API to display trending and now playing movies, with features like search, bookmarking, offline support, and deep linking.

## Features

✅ **Home Page**: Browse trending movies and now playing movies
✅ **Movie Details**: View detailed information about each movie
✅ **Bookmarking**: Save your favorite movies for later viewing
✅ **Search**: Search for movies with debounced search (updates as you type)
✅ **Offline Support**: All movie data is cached locally for offline viewing
✅ **Movie Sharing**: Share movies with deep links
✅ **Deep Linking**: Open specific movies directly from shared links
✅ **Clean Architecture**: MVVM pattern with BLoC state management
✅ **Repository Pattern**: Centralized data management
✅ **Cross-Platform**: Works on Android and iOS

## Architecture

The app follows **MVVM (Model-View-ViewModel)** architecture with the following structure:

```
lib/
├── core/
│   ├── constants/         # API constants and configuration
│   ├── di/               # Dependency injection setup
│   └── services/         # Services like deep linking
├── data/
│   ├── database/         # SQLite database helper
│   ├── models/           # Data models
│   ├── repositories/     # Repository implementation
│   └── services/         # API service (Retrofit)
└── presentation/
    ├── bloc/            # BLoC state management
    ├── pages/           # UI screens
    └── widgets/         # Reusable widgets
```

## Technologies Used

-   **Flutter**: Cross-platform mobile framework
-   **BLoC**: State management
-   **Retrofit**: API networking
-   **SQLite**: Local database for offline storage
-   **GetIt**: Dependency injection
-   **Dio**: HTTP client
-   **Cached Network Image**: Image caching
-   **Share Plus**: Sharing functionality
-   **Uni Links**: Deep linking support
-   **Connectivity Plus**: Network connectivity detection

## Setup Instructions

### 1. Get TMDB API Key

1. Visit [The Movie Database (TMDB)](https://www.themoviedb.org/)
2. Create a free account
3. Go to Settings → API → Create API Key
4. Copy your API key

### 2. Configure API Key

Open `lib/core/constants/api_constants.dart` and replace the placeholder with your API key:

```dart
static const String apiKey = 'YOUR_TMDB_API_KEY'; // Replace with your actual API key
```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Run Code Generation

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 5. Run the App

```bash
# For Android
flutter run

# For iOS
flutter run

# For specific device
flutter run -d <device_id>
```

## Features Explained

### 1. Home Page

-   Displays two horizontal scrollable lists:
    -   **Trending Movies**: Popular movies this week
    -   **Now Playing**: Movies currently in theaters
-   Pull-to-refresh to update movie lists
-   Tap on any movie to view details
-   Bookmark icon on each movie card

### 2. Movie Details Page

-   Full movie information including:
    -   Backdrop image
    -   Title and tagline
    -   Rating and vote count
    -   Release year and duration
    -   Overview/synopsis
    -   Genres
    -   Production details
-   Bookmark button to save movie
-   Share button to share movie with deep link

### 3. Bookmarks Page

-   Grid view of all bookmarked movies
-   Tap to view movie details
-   Tap bookmark icon to remove from bookmarks
-   Empty state when no bookmarks

### 4. Search Page

-   Debounced search (updates 500ms after you stop typing)
-   Real-time search results as you type
-   Grid view of search results
-   Clear search button
-   No results state

### 5. Offline Support

-   All API responses are cached in SQLite database
-   When offline, app displays cached data
-   Bookmarks are stored locally and always available
-   Automatic cache management

### 6. Movie Sharing & Deep Linking

-   Share movies with friends using the share button
-   Generates deep links: `movieapp://movie/{movie_id}`
-   When users click on the deep link, app opens directly to that movie
-   Works even if app is closed

## Deep Linking Setup

### Android

The `AndroidManifest.xml` is already configured with:

```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="movieapp" />
</intent-filter>
```

### iOS

Add to `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>movieapp</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>movieapp</string>
        </array>
    </dict>
</array>
```

## Testing Deep Links

### Android

```bash
adb shell am start -W -a android.intent.action.VIEW -d "movieapp://movie/550"
```

### iOS Simulator

```bash
xcrun simctl openurl booted "movieapp://movie/550"
```

## Project Structure Details

### BLoC Pattern

-   **MovieBloc**: Manages trending and now playing movies state
-   **SearchBloc**: Handles search functionality with debouncing
-   **BookmarkBloc**: Manages bookmarked movies state

### Repository Pattern

-   Single source of truth for data
-   Handles both API calls and local database operations
-   Automatic caching and offline support
-   Network connectivity detection

### Database Schema

-   **bookmarked_movies**: Stores user bookmarks
-   **cached_movies**: Caches API responses with cache type (trending/now_playing)

## Performance Optimizations

1. **Image Caching**: Uses `cached_network_image` for efficient image loading
2. **Debounced Search**: Reduces API calls during search
3. **Lazy Loading**: BLoC state management ensures efficient rebuilds
4. **Database Indexing**: Optimized queries for fast data retrieval
5. **Network Detection**: Prevents unnecessary API calls when offline

## Error Handling

-   Network errors: Falls back to cached data
-   Empty states: User-friendly messages for empty lists
-   Loading states: Progress indicators during data fetching
-   Retry mechanisms: Users can retry failed operations

## UI/UX Features

-   Material Design 3
-   Smooth animations and transitions
-   Pull-to-refresh functionality
-   Empty state illustrations
-   Loading indicators
-   Error messages with retry options
-   Responsive design for different screen sizes

## Build for Release

### Android

```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

## Troubleshooting

### Issue: Movies not loading

**Solution**: Check your API key is correct in `api_constants.dart`

### Issue: Deep links not working

**Solution**:

-   Android: Verify AndroidManifest.xml intent filter
-   iOS: Add CFBundleURLTypes to Info.plist

### Issue: Build errors

**Solution**: Run `flutter clean && flutter pub get && flutter pub run build_runner build --delete-conflicting-outputs`

## Future Enhancements

-   [ ] Movie trailers and videos
-   [ ] User reviews and ratings
-   [ ] Movie recommendations
-   [ ] Watchlist with categories
-   [ ] Dark/Light theme toggle
-   [ ] Multiple language support
-   [ ] Movie filters and sorting

## Contributing

Feel free to submit issues and enhancement requests!

## License

This project is for educational purposes and uses The Movie Database (TMDB) API.

## Credits

-   [The Movie Database (TMDB)](https://www.themoviedb.org/) for movie data
-   Flutter and Dart teams for the excellent framework

---

**Note**: Remember to replace `YOUR_TMDB_API_KEY` with your actual API key before running the app!
