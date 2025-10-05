import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/movie_details_model.dart';
import '../../data/repositories/movie_repository.dart';

abstract class MovieDetailsEvent extends Equatable {
  const MovieDetailsEvent();

  @override
  List<Object> get props => [];
}

class LoadMovieDetails extends MovieDetailsEvent {
  final int movieId;

  const LoadMovieDetails(this.movieId);

  @override
  List<Object> get props => [movieId];
}

class RefreshMovieDetails extends MovieDetailsEvent {
  final int movieId;

  const RefreshMovieDetails(this.movieId);

  @override
  List<Object> get props => [movieId];
}

abstract class MovieDetailsState extends Equatable {
  const MovieDetailsState();

  @override
  List<Object> get props => [];
}

class MovieDetailsInitial extends MovieDetailsState {}

class MovieDetailsLoading extends MovieDetailsState {}

class MovieDetailsLoaded extends MovieDetailsState {
  final MovieDetailsModel movieDetails;

  const MovieDetailsLoaded(this.movieDetails);

  @override
  List<Object> get props => [movieDetails];
}

class MovieDetailsError extends MovieDetailsState {
  final String message;

  const MovieDetailsError(this.message);

  @override
  List<Object> get props => [message];
}

class MovieDetailsBloc extends Bloc<MovieDetailsEvent, MovieDetailsState> {
  final MovieRepository _movieRepository;

  MovieDetailsBloc({required MovieRepository movieRepository})
      : _movieRepository = movieRepository,
        super(MovieDetailsInitial()) {
    on<LoadMovieDetails>(_onLoadMovieDetails);
    on<RefreshMovieDetails>(_onRefreshMovieDetails);
  }

  Future<void> _onLoadMovieDetails(
    LoadMovieDetails event,
    Emitter<MovieDetailsState> emit,
  ) async {
    try {
      emit(MovieDetailsLoading());
      final details = await _movieRepository.getMovieDetails(event.movieId);
      emit(MovieDetailsLoaded(details));
    } catch (e) {
      emit(MovieDetailsError(e.toString()));
    }
  }

  Future<void> _onRefreshMovieDetails(
    RefreshMovieDetails event,
    Emitter<MovieDetailsState> emit,
  ) async {
    try {
      emit(MovieDetailsLoading());
      final details = await _movieRepository.getMovieDetails(event.movieId);
      emit(MovieDetailsLoaded(details));
    } catch (e) {
      emit(MovieDetailsError(e.toString()));
    }
  }
}
