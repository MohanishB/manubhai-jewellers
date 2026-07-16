part of 'safe_keeper_update_bloc.dart';

abstract class SafeKeeperUpdateState {}

class SafeKeeperUpdateInitial extends SafeKeeperUpdateState {}

class SafeKeeperUpdateLoading extends SafeKeeperUpdateState {}

class SafeKeeperUpdateSuccess extends SafeKeeperUpdateState {}

class SafeKeeperUpdateError extends SafeKeeperUpdateState {
  final String message;
  SafeKeeperUpdateError(this.message);
}
