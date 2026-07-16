import 'package:equatable/equatable.dart';
import '../data/models/auth_user_model.dart';

sealed class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthUnknown extends AuthState {
  const AuthUnknown();
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final AuthUser user;
  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
