import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/movie_model.dart';
import '../../data/repositories/movie_repository.dart';

abstract class BookmarkEvent extends Equatable {
  const BookmarkEvent();

  @override
  List<Object> get props => [];
}

class LoadBookmarkedMovies extends BookmarkEvent {}

class ToggleBookmark extends BookmarkEvent {
  final MovieModel movie;

  const ToggleBookmark(this.movie);

  @override
  List<Object> get props => [movie];
}

class RemoveBookmark extends BookmarkEvent {
  final int movieId;

  const RemoveBookmark(this.movieId);

  @override
  List<Object> get props => [movieId];
}

class CheckBookmarkStatus extends BookmarkEvent {
  final int movieId;

  const CheckBookmarkStatus(this.movieId);

  @override
  List<Object> get props => [movieId];
}

abstract class BookmarkState extends Equatable {
  const BookmarkState();

  @override
  List<Object> get props => [];
}

class BookmarkInitial extends BookmarkState {}

class BookmarkLoading extends BookmarkState {}

class BookmarkLoaded extends BookmarkState {
  final List<MovieModel> bookmarkedMovies;
  final Map<int, bool> bookmarkStatus;

  const BookmarkLoaded({
    required this.bookmarkedMovies,
    required this.bookmarkStatus,
  });

  @override
  List<Object> get props => [bookmarkedMovies, bookmarkStatus];
}

class BookmarkError extends BookmarkState {
  final String message;

  const BookmarkError(this.message);

  @override
  List<Object> get props => [message];
}

class BookmarkBloc extends Bloc<BookmarkEvent, BookmarkState> {
  final MovieRepository _movieRepository;

  BookmarkBloc({required MovieRepository movieRepository})
      : _movieRepository = movieRepository,
        super(BookmarkInitial()) {
    on<LoadBookmarkedMovies>(_onLoadBookmarkedMovies);
    on<ToggleBookmark>(_onToggleBookmark);
    on<RemoveBookmark>(_onRemoveBookmark);
    on<CheckBookmarkStatus>(_onCheckBookmarkStatus);
  }

  Future<void> _onLoadBookmarkedMovies(
    LoadBookmarkedMovies event,
    Emitter<BookmarkState> emit,
  ) async {
    try {
      emit(BookmarkLoading());
      final bookmarkedMovies = await _movieRepository.getBookmarkedMovies();

      final bookmarkStatus = <int, bool>{};
      for (final movie in bookmarkedMovies) {
        bookmarkStatus[movie.id] = true;
      }

      emit(BookmarkLoaded(
        bookmarkedMovies: bookmarkedMovies,
        bookmarkStatus: bookmarkStatus,
      ));
    } catch (e) {
      emit(BookmarkError(e.toString()));
    }
  }

  Future<void> _onToggleBookmark(
    ToggleBookmark event,
    Emitter<BookmarkState> emit,
  ) async {
    try {
      final isBookmarked =
          await _movieRepository.isMovieBookmarked(event.movie.id);

      if (isBookmarked) {
        await _movieRepository.removeBookmark(event.movie.id);
      } else {
        await _movieRepository.bookmarkMovie(event.movie);
      }

      add(LoadBookmarkedMovies());
    } catch (e) {
      emit(BookmarkError(e.toString()));
    }
  }

  Future<void> _onRemoveBookmark(
    RemoveBookmark event,
    Emitter<BookmarkState> emit,
  ) async {
    try {
      await _movieRepository.removeBookmark(event.movieId);
      add(LoadBookmarkedMovies());
    } catch (e) {
      emit(BookmarkError(e.toString()));
    }
  }

  Future<void> _onCheckBookmarkStatus(
    CheckBookmarkStatus event,
    Emitter<BookmarkState> emit,
  ) async {
    try {
      final isBookmarked =
          await _movieRepository.isMovieBookmarked(event.movieId);

      if (state is BookmarkLoaded) {
        final currentState = state as BookmarkLoaded;
        final updatedStatus = Map<int, bool>.from(currentState.bookmarkStatus);
        updatedStatus[event.movieId] = isBookmarked;

        emit(BookmarkLoaded(
          bookmarkedMovies: currentState.bookmarkedMovies,
          bookmarkStatus: updatedStatus,
        ));
      }
    } catch (e) {
      emit(BookmarkError(e.toString()));
    }
  }
}
