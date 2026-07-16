import 'package:equatable/equatable.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthAppStarted extends AuthEvent {
  const AuthAppStarted();
}

class AuthLoginRequested extends AuthEvent {
  final String username;
  final String password;
  final String deviceToken;
  final String cseDevice;

  const AuthLoginRequested({
    required this.username,
    required this.password,
    required this.deviceToken,
    required this.cseDevice,
  });

  @override
  List<Object?> get props => [username, password];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
