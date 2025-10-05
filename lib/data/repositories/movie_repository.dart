import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/movie_model.dart';
import '../models/movie_details_model.dart';
import '../services/api_service.dart';
import '../database/database_helper.dart';
import '../../core/constants/api_constants.dart';

class MovieRepository {
  final ApiService _apiService;
  final DatabaseHelper _databaseHelper;
  final Connectivity _connectivity;

  MovieRepository({
    required ApiService apiService,
    required DatabaseHelper databaseHelper,
    required Connectivity connectivity,
  })  : _apiService = apiService,
        _databaseHelper = databaseHelper,
        _connectivity = connectivity;

  Future<bool> get _isConnected async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return !connectivityResult.contains(ConnectivityResult.none);
  }

  Future<List<MovieModel>> getTrendingMovies({int page = 1}) async {
    try {
      if (await _isConnected) {
        final response = await _apiService.getTrendingMovies(
          ApiConstants.apiKey,
          page,
        );
        await _databaseHelper.insertCachedMovies(
          response.results.map((movie) => movie.toJson()).toList(),
          'trending',
        );

        return response.results;
      } else {
        final cachedData = await _databaseHelper.getCachedMovies('trending');
        return cachedData.map((json) => MovieModel.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error fetching trending movies: $e');
      try {
        final cachedData = await _databaseHelper.getCachedMovies('trending');
        if (cachedData.isNotEmpty) {
          return cachedData.map((json) => MovieModel.fromJson(json)).toList();
        }
      } catch (cacheError) {
        print('Error loading cached data: $cacheError');
      }
      return [];
    }
  }

  Future<List<MovieModel>> getNowPlayingMovies({int page = 1}) async {
    try {
      if (await _isConnected) {
        final response = await _apiService.getNowPlayingMovies(
          ApiConstants.apiKey,
          page,
        );
        await _databaseHelper.insertCachedMovies(
          response.results.map((movie) => movie.toJson()).toList(),
          'now_playing',
        );

        return response.results;
      } else {
        final cachedData = await _databaseHelper.getCachedMovies('now_playing');
        return cachedData.map((json) => MovieModel.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error fetching now playing movies: $e');
      try {
        final cachedData = await _databaseHelper.getCachedMovies('now_playing');
        if (cachedData.isNotEmpty) {
          return cachedData.map((json) => MovieModel.fromJson(json)).toList();
        }
      } catch (cacheError) {
        print('Error loading cached data: $cacheError');
      }
      return [];
    }
  }

  Future<List<MovieModel>> searchMovies(String query, {int page = 1}) async {
    if (query.isEmpty) return [];

    try {
      if (await _isConnected) {
        final response = await _apiService.searchMovies(
          ApiConstants.apiKey,
          query,
          false,
          'en-US',
          page,
        );
        return response.results;
      } else {
        return [];
      }
    } catch (e) {
      print('Error searching movies: $e');
      return [];
    }
  }

  Future<MovieDetailsModel> getMovieDetails(int movieId) async {
    try {
      if (await _isConnected) {
        print('getMovieDetails: $movieId');
        await Future.delayed(const Duration(milliseconds: 500));

        final details =
            await _apiService.getMovieDetails(movieId, ApiConstants.apiKey);
        await _databaseHelper.insertCachedMovies(
          [details.toJson()],
          'movie_details',
        );

        print('Movie details cached successfully for ID: $movieId');
        return details;
      } else {
        final cachedData = await _databaseHelper.getCachedMovieDetails(movieId);
        if (cachedData != null) {
          print('Retrieved movie details from cache for ID: $movieId');
          return MovieDetailsModel.fromJson(cachedData);
        }
        throw Exception(
            'No internet connection and no cached data for movie ID: $movieId');
      }
    } catch (e) {
      print('Error fetching movie details: $e');
      try {
        final cachedData = await _databaseHelper.getCachedMovieDetails(movieId);
        if (cachedData != null) {
          print('Using cached movie details as fallback for ID: $movieId');
          return MovieDetailsModel.fromJson(cachedData);
        }
      } catch (cacheError) {
        print('Error loading cached movie details: $cacheError');
      }
      throw Exception(
          'No internet connection and no cached data for movie ID: $movieId');
    }
  }

  Future<void> bookmarkMovie(MovieModel movie) async {
    await _databaseHelper.insertBookmarkedMovie(movie);
  }

  Future<void> removeBookmark(int movieId) async {
    await _databaseHelper.removeBookmarkedMovie(movieId);
  }

  Future<List<MovieModel>> getBookmarkedMovies() async {
    return await _databaseHelper.getBookmarkedMovies();
  }

  Future<bool> isMovieBookmarked(int movieId) async {
    return await _databaseHelper.isMovieBookmarked(movieId);
  }
}
