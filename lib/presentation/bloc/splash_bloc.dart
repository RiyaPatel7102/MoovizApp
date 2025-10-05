import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class SplashEvent extends Equatable {
  const SplashEvent();

  @override
  List<Object> get props => [];
}

class SplashStarted extends SplashEvent {}

class SplashCompleted extends SplashEvent {}

// States
abstract class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object> get props => [];
}

class SplashInitial extends SplashState {}

class SplashLoading extends SplashState {}

class SplashLoaded extends SplashState {}

// Bloc
class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(SplashInitial()) {
    on<SplashStarted>(_onSplashStarted);
    on<SplashCompleted>(_onSplashCompleted);
  }

  void _onSplashStarted(SplashStarted event, Emitter<SplashState> emit) async {
    emit(SplashLoading());

    // Simulate splash screen duration (3 seconds)
    await Future.delayed(const Duration(seconds: 3));

    emit(SplashLoaded());
  }

  void _onSplashCompleted(SplashCompleted event, Emitter<SplashState> emit) {
    emit(SplashLoaded());
  }
}
