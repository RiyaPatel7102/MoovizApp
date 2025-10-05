import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/movie_model.dart';
import '../../data/repositories/movie_repository.dart';

// Events
abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object> get props => [];
}

class SearchQueryChanged extends SearchEvent {
  final String query;

  const SearchQueryChanged(this.query);

  @override
  List<Object> get props => [query];
}

class SearchCleared extends SearchEvent {}

// States
abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<MovieModel> movies;
  final String query;

  const SearchLoaded({
    required this.movies,
    required this.query,
  });

  @override
  List<Object> get props => [movies, query];
}

class SearchError extends SearchState {
  final String message;

  const SearchError(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final MovieRepository _movieRepository;
  Timer? _debounceTimer;

  SearchBloc({required MovieRepository movieRepository})
      : _movieRepository = movieRepository,
        super(SearchInitial()) {
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<SearchCleared>(_onSearchCleared);
  }

  Future<void> _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    _debounceTimer?.cancel();

    if (event.query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    // Use Completer to properly handle async operations
    final completer = Completer<void>();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      try {
        if (!emit.isDone) {
          emit(SearchLoading());
        }

        final movies = await _movieRepository.searchMovies(event.query);

        if (!emit.isDone) {
          emit(SearchLoaded(movies: movies, query: event.query));
        }

        completer.complete();
      } catch (e) {
        if (!emit.isDone) {
          emit(SearchError(e.toString()));
        }
        completer.complete();
      }
    });

    // Wait for the debounced operation to complete
    await completer.future;
  }

  void _onSearchCleared(
    SearchCleared event,
    Emitter<SearchState> emit,
  ) {
    _debounceTimer?.cancel();
    emit(SearchInitial());
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
