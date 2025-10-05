# Quick Setup Guide

## Step 1: Get Your TMDB API Key

1. Go to https://www.themoviedb.org/
2. Sign up for a free account
3. Go to Settings → API
4. Request an API key (it's instant and free)
5. Copy your API Key (v3 auth)

## Step 2: Add API Key to the Project

Open the file: `lib/core/constants/api_constants.dart`

Replace this line:

```dart
static const String apiKey = 'YOUR_TMDB_API_KEY';
```

With your actual API key:

```dart
static const String apiKey = 'a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6';  // Example
```

## Step 3: Install Dependencies

```bash
flutter pub get
```

## Step 4: Generate Code

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This will generate all necessary files for:

-   JSON serialization
-   Retrofit API service

## Step 5: Run the App

```bash
flutter run
```

That's it! You're ready to use the app.

## Testing the App

### Home Screen

-   You should see trending and now playing movies
-   Pull down to refresh
-   Tap on any movie to see details

### Movie Details

-   View full movie information
-   Tap bookmark icon to save
-   Tap share icon to share with deep link

### Search

-   Tap search icon in home screen
-   Start typing to search movies
-   Results update as you type (with 500ms delay)

### Bookmarks

-   Tap bookmark icon in home screen
-   View all your saved movies
-   Tap bookmark icon again to remove

## Testing Deep Links

### Android (using ADB)

```bash
# Replace 550 with any movie ID
adb shell am start -W -a android.intent.action.VIEW -d "movieapp://movie/550"
```

### iOS Simulator

```bash
# Replace 550 with any movie ID
xcrun simctl openurl booted "movieapp://movie/550"
```

## Popular Movie IDs for Testing

-   550 - Fight Club
-   238 - The Godfather
-   680 - Pulp Fiction
-   155 - The Dark Knight
-   13 - Forrest Gump

## Troubleshooting

### Problem: "API Key is invalid"

**Solution**: Make sure you copied the entire API key correctly without any spaces

### Problem: "No movies showing"

**Solution**:

1. Check your internet connection
2. Verify your API key is correct
3. Check if TMDB API is accessible in your region

### Problem: "Build errors after adding dependencies"

**Solution**:

```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Problem: "Deep links not working"

**Solution**:

-   Make sure you've added the intent filter in AndroidManifest.xml (already done)
-   For iOS, make sure Info.plist has CFBundleURLTypes (already done)
-   Restart the app after configuration changes

## Features Checklist

✅ Home page with trending movies
✅ Home page with now playing movies
✅ Movie details page
✅ Navigation between pages
✅ Bookmark movies
✅ Saved movies page
✅ Offline support (cached data)
✅ Search functionality
✅ Debounced search (bonus task)
✅ Share movies (bonus task)
✅ Deep linking (bonus task)

## Architecture

-   **State Management**: BLoC
-   **Networking**: Retrofit + Dio
-   **Local Database**: SQLite (sqflite)
-   **Dependency Injection**: GetIt
-   **Architecture Pattern**: MVVM
-   **Data Layer**: Repository Pattern
-   **Platforms**: Android & iOS

## Next Steps

1. Customize the app theme in `lib/main.dart`
2. Add more features like favorites categories
3. Implement movie trailers
4. Add user reviews section
5. Create a watchlist feature

Enjoy building with the MovieApp! 🎬
