import 'dart:convert';

import 'package:movie_app/data/models/movie_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'movies.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE cached_movies ADD COLUMN genres TEXT');
      await db.execute(
          'ALTER TABLE cached_movies ADD COLUMN production_companies TEXT');
      await db.execute(
          'ALTER TABLE cached_movies ADD COLUMN spoken_languages TEXT');
      await db.execute(
          'ALTER TABLE cached_movies ADD COLUMN production_countries TEXT');
      await db
          .execute('ALTER TABLE cached_movies ADD COLUMN origin_country TEXT');
      await db.execute(
          'ALTER TABLE cached_movies ADD COLUMN belongs_to_collection TEXT');
      await db.execute('ALTER TABLE cached_movies ADD COLUMN budget INTEGER');
      await db.execute('ALTER TABLE cached_movies ADD COLUMN revenue INTEGER');
      await db.execute('ALTER TABLE cached_movies ADD COLUMN homepage TEXT');
      await db.execute('ALTER TABLE cached_movies ADD COLUMN imdb_id TEXT');
      await db.execute('ALTER TABLE cached_movies ADD COLUMN runtime INTEGER');
      await db.execute('ALTER TABLE cached_movies ADD COLUMN status TEXT');
      await db.execute('ALTER TABLE cached_movies ADD COLUMN tagline TEXT');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE bookmarked_movies(
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        overview TEXT NOT NULL,
        poster_path TEXT,
        backdrop_path TEXT,
        release_date TEXT,
        vote_average REAL NOT NULL,
        vote_count INTEGER NOT NULL,
        adult INTEGER NOT NULL,
        original_language TEXT NOT NULL,
        original_title TEXT NOT NULL,
        popularity REAL NOT NULL,
        video INTEGER NOT NULL,
        bookmarked_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE cached_movies(
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        overview TEXT NOT NULL,
        poster_path TEXT,
        backdrop_path TEXT,
        release_date TEXT,
        vote_average REAL NOT NULL,
        vote_count INTEGER NOT NULL,
        adult INTEGER NOT NULL,
        original_language TEXT NOT NULL,
        original_title TEXT NOT NULL,
        popularity REAL NOT NULL,
        video INTEGER NOT NULL,
        genres TEXT,
        production_companies TEXT,
        spoken_languages TEXT,
        production_countries TEXT,
        origin_country TEXT,
        belongs_to_collection TEXT,
        budget INTEGER,
        revenue INTEGER,
        homepage TEXT,
        imdb_id TEXT,
        runtime INTEGER,
        status TEXT,
        tagline TEXT,
        cache_type TEXT NOT NULL,
        cached_at TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertBookmarkedMovie(MovieModel movie) async {
    final db = await database;

    final movieData = {
      'id': movie.id,
      'title': movie.title,
      'overview': movie.overview,
      'poster_path': movie.posterPath,
      'backdrop_path': movie.backdropPath,
      'release_date': movie.releaseDate,
      'vote_average': movie.voteAverage,
      'vote_count': movie.voteCount,
      'adult': movie.isAdult ? 1 : 0,
      'original_language': movie.originalLanguage,
      'original_title': movie.originalTitle,
      'popularity': movie.popularity,
      'video': movie.hasVideo ? 1 : 0,
      'bookmarked_at': DateTime.now().toIso8601String(),
    };

    return await db.insert(
      'bookmarked_movies',
      movieData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<MovieModel>> getBookmarkedMovies() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bookmarked_movies',
      orderBy: 'bookmarked_at DESC',
    );

    return List.generate(maps.length, (i) {
      final movieData = Map<String, dynamic>.from(maps[i]);
      movieData['adult'] = (maps[i]['adult'] == 1);
      movieData['video'] = (maps[i]['video'] == 1);
      return MovieModel.fromJson(movieData);
    });
  }

  Future<bool> isMovieBookmarked(int movieId) async {
    final db = await database;
    final result = await db.query(
      'bookmarked_movies',
      where: 'id = ?',
      whereArgs: [movieId],
    );
    return result.isNotEmpty;
  }

  Future<int> removeBookmarkedMovie(int movieId) async {
    final db = await database;
    return await db.delete(
      'bookmarked_movies',
      where: 'id = ?',
      whereArgs: [movieId],
    );
  }

  Future<int> insertCachedMovies(
      List<Map<String, dynamic>> movies, String cacheType) async {
    final db = await database;
    final batch = db.batch();

    if (cacheType == 'movie_details') {
      for (final movie in movies) {
        batch.delete('cached_movies',
            where: 'cache_type = ? AND id = ?',
            whereArgs: [cacheType, movie['id']]);
      }
    } else {
      batch.delete('cached_movies',
          where: 'cache_type = ?', whereArgs: [cacheType]);
    }

    for (final movie in movies) {
      final movieData = Map<String, dynamic>.from(movie);
      movieData['cache_type'] = cacheType;
      movieData['cached_at'] = DateTime.now().toIso8601String();

      movieData.remove('bookmarked_at');
      movieData['adult'] = (movie['adult'] == true) ? 1 : 0;
      movieData['video'] = (movie['video'] == true) ? 1 : 0;

      if (movieData['genres'] != null) {
        movieData['genres'] = jsonEncode(movieData['genres']);
      }
      if (movieData['production_companies'] != null) {
        movieData['production_companies'] =
            jsonEncode(movieData['production_companies']);
      }
      if (movieData['spoken_languages'] != null) {
        movieData['spoken_languages'] =
            jsonEncode(movieData['spoken_languages']);
      }
      if (movieData['production_countries'] != null) {
        movieData['production_countries'] =
            jsonEncode(movieData['production_countries']);
      }
      if (movieData['origin_country'] != null) {
        movieData['origin_country'] = jsonEncode(movieData['origin_country']);
      }
      if (movieData['belongs_to_collection'] != null) {
        movieData['belongs_to_collection'] =
            jsonEncode(movieData['belongs_to_collection']);
      }

      movieData.remove('genre_ids');

      batch.insert('cached_movies', movieData,
          conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit();
    return movies.length;
  }

  Future<List<Map<String, dynamic>>> getCachedMovies(String cacheType) async {
    final db = await database;

    final expiryTime = DateTime.now().subtract(const Duration(hours: 24));
    await db.delete(
      'cached_movies',
      where: 'cached_at < ?',
      whereArgs: [expiryTime.toIso8601String()],
    );

    final results = await db.query(
      'cached_movies',
      where: 'cache_type = ?',
      whereArgs: [cacheType],
      orderBy: 'cached_at DESC',
    );

    return results.map((movie) {
      final movieData = Map<String, dynamic>.from(movie);
      movieData['adult'] = (movie['adult'] == 1);
      movieData['video'] = (movie['video'] == 1);

      if (movieData['genres'] != null) {
        movieData['genres'] = jsonDecode(movieData['genres']);
      }
      if (movieData['production_companies'] != null) {
        movieData['production_companies'] =
            jsonDecode(movieData['production_companies']);
      }
      if (movieData['spoken_languages'] != null) {
        movieData['spoken_languages'] =
            jsonDecode(movieData['spoken_languages']);
      }
      if (movieData['production_countries'] != null) {
        movieData['production_countries'] =
            jsonDecode(movieData['production_countries']);
      }
      if (movieData['origin_country'] != null) {
        movieData['origin_country'] = jsonDecode(movieData['origin_country']);
      }
      if (movieData['belongs_to_collection'] != null) {
        movieData['belongs_to_collection'] =
            jsonDecode(movieData['belongs_to_collection']);
      }

      return movieData;
    }).toList();
  }

  Future<void> clearCache() async {
    final db = await database;
    await db.delete('cached_movies');
  }

  Future<Map<String, dynamic>?> getCachedMovieDetails(int movieId) async {
    final db = await database;

    final expiryTime = DateTime.now().subtract(const Duration(hours: 24));
    await db.delete(
      'cached_movies',
      where: 'cached_at < ?',
      whereArgs: [expiryTime.toIso8601String()],
    );

    final results = await db.query(
      'cached_movies',
      where: 'cache_type = ? AND id = ?',
      whereArgs: ['movie_details', movieId],
      limit: 1,
    );

    if (results.isEmpty) return null;

    final movie = results.first;
    final movieData = Map<String, dynamic>.from(movie);

    movieData['adult'] = (movie['adult'] == 1);
    movieData['video'] = (movie['video'] == 1);

    if (movieData['genres'] != null) {
      movieData['genres'] = jsonDecode(movieData['genres']);
    }
    if (movieData['production_companies'] != null) {
      movieData['production_companies'] =
          jsonDecode(movieData['production_companies']);
    }
    if (movieData['spoken_languages'] != null) {
      movieData['spoken_languages'] = jsonDecode(movieData['spoken_languages']);
    }
    if (movieData['production_countries'] != null) {
      movieData['production_countries'] =
          jsonDecode(movieData['production_countries']);
    }
    if (movieData['origin_country'] != null) {
      movieData['origin_country'] = jsonDecode(movieData['origin_country']);
    }
    if (movieData['belongs_to_collection'] != null) {
      movieData['belongs_to_collection'] =
          jsonDecode(movieData['belongs_to_collection']);
    }

    return movieData;
  }
}
