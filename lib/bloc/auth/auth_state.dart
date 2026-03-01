import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthState extends Equatable {
  final bool loading;
  final User? user;
  final String? error;

  const AuthState({
    this.loading = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? loading,
    User? user,
    String? error,
  }) {
    return AuthState(
      loading: loading ?? this.loading,
      user: user ?? this.user,
      error: error,
    );
  }

  @override
  List<Object?> get props => [loading, user, error];
}