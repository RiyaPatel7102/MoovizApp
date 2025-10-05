import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../core/services/deep_link_service.dart';

abstract class AppEvent extends Equatable {
  const AppEvent();

  @override
  List<Object> get props => [];
}

class InitializeApp extends AppEvent {}

class DeepLinkReceived extends AppEvent {
  final int movieId;

  const DeepLinkReceived(this.movieId);

  @override
  List<Object> get props => [movieId];
}

class AppDisposed extends AppEvent {}

abstract class AppState extends Equatable {
  const AppState();

  @override
  List<Object> get props => [];
}

class AppInitial extends AppState {}

class AppInitialized extends AppState {}

class AppNavigationRequested extends AppState {
  final int movieId;

  const AppNavigationRequested(this.movieId);

  @override
  List<Object> get props => [movieId];
}

class AppBloc extends Bloc<AppEvent, AppState> {
  final DeepLinkService _deepLinkService;
  StreamSubscription? _deepLinkSubscription;

  AppBloc({required DeepLinkService deepLinkService})
      : _deepLinkService = deepLinkService,
        super(AppInitial()) {
    on<InitializeApp>(_onInitializeApp);
    on<DeepLinkReceived>(_onDeepLinkReceived);
    on<AppDisposed>(_onAppDisposed);
  }

  Future<void> _onInitializeApp(
    InitializeApp event,
    Emitter<AppState> emit,
  ) async {
    try {
      _deepLinkSubscription = _deepLinkService.movieIdStream.listen((movieId) {
        add(DeepLinkReceived(movieId));
      });
      emit(AppInitialized());
    } catch (e) {
      emit(AppInitialized());
    }
  }

  void _onDeepLinkReceived(
    DeepLinkReceived event,
    Emitter<AppState> emit,
  ) {
    emit(AppNavigationRequested(event.movieId));
  }

  void _onAppDisposed(
    AppDisposed event,
    Emitter<AppState> emit,
  ) {
    _deepLinkSubscription?.cancel();
    emit(AppInitial());
  }

  @override
  Future<void> close() {
    _deepLinkSubscription?.cancel();
    return super.close();
  }
}
