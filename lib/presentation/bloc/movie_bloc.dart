import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/movie_model.dart';
import '../../data/repositories/movie_repository.dart';

// Events
abstract class MovieEvent extends Equatable {
  const MovieEvent();

  @override
  List<Object> get props => [];
}

class LoadTrendingMovies extends MovieEvent {
  final int page;

  const LoadTrendingMovies({this.page = 1});

  @override
  List<Object> get props => [page];
}

class LoadNowPlayingMovies extends MovieEvent {
  final int page;

  const LoadNowPlayingMovies({this.page = 1});

  @override
  List<Object> get props => [page];
}

class RefreshMovies extends MovieEvent {}

// States
abstract class MovieState extends Equatable {
  const MovieState();

  @override
  List<Object> get props => [];
}

class MovieInitial extends MovieState {}

class MovieLoading extends MovieState {}

class MovieLoaded extends MovieState {
  final List<MovieModel> trendingMovies;
  final List<MovieModel> nowPlayingMovies;

  const MovieLoaded({
    required this.trendingMovies,
    required this.nowPlayingMovies,
  });

  @override
  List<Object> get props => [trendingMovies, nowPlayingMovies];
}

class MovieError extends MovieState {
  final String message;

  const MovieError(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class MovieBloc extends Bloc<MovieEvent, MovieState> {
  final MovieRepository _movieRepository;

  MovieBloc({required MovieRepository movieRepository})
      : _movieRepository = movieRepository,
        super(MovieInitial()) {
    on<LoadTrendingMovies>(_onLoadTrendingMovies);
    on<LoadNowPlayingMovies>(_onLoadNowPlayingMovies);
    on<RefreshMovies>(_onRefreshMovies);
  }

  Future<void> _onLoadTrendingMovies(
    LoadTrendingMovies event,
    Emitter<MovieState> emit,
  ) async {
    try {
      emit(MovieLoading());
      final trendingMovies =
          await _movieRepository.getTrendingMovies(page: event.page);
      final nowPlayingMovies = await _movieRepository.getNowPlayingMovies();

      emit(MovieLoaded(
        trendingMovies: trendingMovies,
        nowPlayingMovies: nowPlayingMovies,
      ));
    } catch (e) {
      emit(MovieError(e.toString()));
    }
  }

  Future<void> _onLoadNowPlayingMovies(
    LoadNowPlayingMovies event,
    Emitter<MovieState> emit,
  ) async {
    try {
      if (state is MovieLoaded) {
        final currentState = state as MovieLoaded;
        final nowPlayingMovies =
            await _movieRepository.getNowPlayingMovies(page: event.page);

        emit(MovieLoaded(
          trendingMovies: currentState.trendingMovies,
          nowPlayingMovies: nowPlayingMovies,
        ));
      }
    } catch (e) {
      emit(MovieError(e.toString()));
    }
  }

  Future<void> _onRefreshMovies(
    RefreshMovies event,
    Emitter<MovieState> emit,
  ) async {
    try {
      emit(MovieLoading());
      final trendingMovies = await _movieRepository.getTrendingMovies();
      final nowPlayingMovies = await _movieRepository.getNowPlayingMovies();

      emit(MovieLoaded(
        trendingMovies: trendingMovies,
        nowPlayingMovies: nowPlayingMovies,
      ));
    } catch (e) {
      emit(MovieError(e.toString()));
    }
  }
}
