import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _service = AuthService();

  AuthBloc() : super(AuthState(user: AuthService().currentUser)) {
    on<LoginRequested>(_onLogin);
    on<SignupRequested>(_onSignup);
    on<LogoutRequested>(_onLogout);
  }

  Future<void> _onLogin(
      LoginRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(state.copyWith(loading: true, error: null));

    final user = await _service.login(event.email, event.password);

    if (user != null) {
      emit(state.copyWith(loading: false, user: user));
    } else {
      emit(state.copyWith(
          loading: false, error: "LOGIN FAILED"));
    }
  }

  Future<void> _onSignup(
      SignupRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(state.copyWith(loading: true, error: null));

    final user = await _service.signUp(event.email, event.password);

    if (user != null) {
      emit(state.copyWith(loading: false, user: user));
    } else {
      emit(state.copyWith(
          loading: false, error: "SIGNUP FAILED"));
    }
  }

  Future<void> _onLogout(
      LogoutRequested event,
      Emitter<AuthState> emit,
      ) async {
    await _service.logout();
    emit(const AuthState(user: null));
  }
}