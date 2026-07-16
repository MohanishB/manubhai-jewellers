// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:manubhaimlt/features/mlt/products/bloc/CSE/productFilters/product_filter_bloc.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import 'auth_event.dart';
// import 'auth_state.dart';
// import '../data/models/auth_user_model.dart';
// import '../data/repositories/auth_repository.dart';

// class AuthBloc extends Bloc<AuthEvent, AuthState> {
//   final AuthRepository repository;

//   AuthBloc({required this.repository}) : super(const AuthUnknown()) {
//     on<AuthAppStarted>(_onAppStarted);
//     on<AuthLoginRequested>(_onLoginRequested);
//     on<AuthLogoutRequested>(_onLogoutRequested);
//   }

//   // ---------------------------------------------------------
//   // APP START → check if user is already logged in (session)
//   // ---------------------------------------------------------
//   Future<void> _onAppStarted(AuthAppStarted event, Emitter<AuthState> emit) async {
//     emit(const AuthLoading());

//     final prefs = await SharedPreferences.getInstance();
//     final id = prefs.getString('cse_id');
//     final firstName = prefs.getString('cse_fname');
//     final lastName = prefs.getString('cse_lname');
//     final email = prefs.getString('cse_email');
//     final phone = prefs.getString('cse_phone');
//     final roleStr = prefs.getString('user_type');
//     final firebaseId = prefs.getString('cse_firebase_id');

//     if (id != null && firstName != null && roleStr != null) {
//       final role = roleStr == 'CSE' ? UserRole.cse : UserRole.storeKeeper;

//       final user = AuthUser(
//         id: id,
//         firstName: firstName,
//         lastName: lastName ?? '',
//         email: email ?? '',
//         phone: phone ?? '',
//         firebaseId: firebaseId ?? '',
//         role: role,
//       );

//       emit(AuthAuthenticated(user));
//     } else {
//       emit(const AuthUnauthenticated());
//     }
//   }

//   // ---------------------------------------------------------
//   // LOGIN → call API, save session, then emit authenticated
//   // ---------------------------------------------------------
//   Future<void> _onLoginRequested(AuthLoginRequested event, Emitter<AuthState> emit) async {
//     emit(const AuthLoading());
//     try {
//       final user = await repository.login(
//         username: event.username,
//         password: event.password,
//         deviceToken: event.deviceToken,
//         cseDevice: event.cseDevice,
//       );

//       // ✅ Save session
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('cse_id', user.id);
//       await prefs.setString('cse_fname', user.firstName);
//       await prefs.setString('cse_lname', user.lastName);
//       await prefs.setString('cse_email', user.email);
//       await prefs.setString('cse_phone', user.phone);
//       await prefs.setString('cse_firebase_id', user.firebaseId);
//       await prefs.setString('user_type', user.role == UserRole.cse ? 'CSE' : 'StoreKeeper');

//       emit(AuthAuthenticated(user));
//     } catch (e) {
//       emit(AuthError(ApiErrorHandler.message(e)));
//       emit(const AuthUnauthenticated());
//     }
//   }

//   // ---------------------------------------------------------
//   // LOGOUT → clear session and emit unauthenticated
//   // ---------------------------------------------------------
//   Future<void> _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.clear();
//     emit(const AuthUnauthenticated());
//     // context.read<ProductFilterBloc>().add(ClearProductFilters());
//   }
// }

//==============================================

import 'package:manubhaimlt/core/errors/api_error_handler.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manubhaimlt/features/auth/data/repositories/firebase_log_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/auth_user_model.dart';
import '../data/repositories/auth_repository.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;
  final CSEFirebaseLogRepository firebaseLogRepo;

  AuthBloc({
    required this.repository,
    required this.firebaseLogRepo,
  }) : super(const AuthUnknown()) {
    on<AuthAppStarted>(_onAppStarted);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  // ---------------------------------------------------------
  // APP START → check if user is already logged in (session)
  // ---------------------------------------------------------
  Future<void> _onAppStarted(
      AuthAppStarted event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('cse_id');
    final firstName = prefs.getString('cse_fname');
    final lastName = prefs.getString('cse_lname');
    final email = prefs.getString('cse_email');
    final phone = prefs.getString('cse_phone');
    final roleStr = prefs.getString('user_type');
    final firebaseId = prefs.getString('cse_firebase_id');

    if (id != null && firstName != null && roleStr != null) {
      final role = roleStr == 'CSE' ? UserRole.cse : UserRole.storeKeeper;

      final user = AuthUser(
        id: id,
        firstName: firstName,
        lastName: lastName ?? '',
        email: email ?? '',
        phone: phone ?? '',
        firebaseId: firebaseId ?? '',
        role: role,
      );

      emit(AuthAuthenticated(user));

      // ✅ Send login log if authenticated via session
      try {
        await firebaseLogRepo.logLogin(
            cseId: id, cseFirebaseId: firebaseId ?? '');
        print('📡 [CSE LOGIN LOG] sent successfully on app start');
      } catch (e) {
        print('⚠️ [CSE LOGIN LOG] failed on app start: $e');
      }
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  // ---------------------------------------------------------
  // LOGIN → call API, save session, then emit authenticated
  // ---------------------------------------------------------
  Future<void> _onLoginRequested(
      AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final user = await repository.login(
        username: event.username,
        password: event.password,
        deviceToken: event.deviceToken,
        cseDevice: event.cseDevice,
      );

      // ✅ Save session
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cse_id', user.id);
      await prefs.setString('cse_fname', user.firstName);
      await prefs.setString('cse_lname', user.lastName);
      await prefs.setString('cse_email', user.email);
      await prefs.setString('cse_phone', user.phone);
      await prefs.setString('cse_firebase_id', user.firebaseId);
      await prefs.setString(
          'user_type', user.role == UserRole.cse ? 'CSE' : 'StoreKeeper');

      emit(AuthAuthenticated(user));

      // ✅ Send login log API
      try {
        // final fcmToken = await FirebaseMessaging.instance.getToken() ?? '';
        await firebaseLogRepo.logLogin(
            cseId: user.id, cseFirebaseId: user.firebaseId);
        print('📡 [CSE LOGIN LOG] sent successfully on login');
      } catch (e) {
        print('⚠️ [CSE LOGIN LOG] failed on login: $e');
      }
    } catch (e) {
      emit(AuthError(ApiErrorHandler.message(e)));
      emit(const AuthUnauthenticated());
    }
  }

  // ---------------------------------------------------------
  // LOGOUT → call API, clear session, and emit unauthenticated
  // ---------------------------------------------------------
  Future<void> _onLogoutRequested(
      AuthLogoutRequested event, Emitter<AuthState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final cseId = prefs.getString('cse_id') ?? '';
    final firebaseId = prefs.getString('cse_firebase_id') ?? '';

    // ✅ Send logout log before clearing session
    try {
      final res = await firebaseLogRepo.logLogout(
        cseId: cseId,
        cseFirebaseId: firebaseId,
      );

      if (res.successCode == 1 && res.errorCode == 0) {
        print('✅ [CSE LOGOUT LOG] success, clearing prefs...');
        await prefs.clear();
        emit(const AuthUnauthenticated());
      } else {
        print('⚠️ [CSE LOGOUT LOG] failed server-side, not clearing prefs yet');
        return; // or handle gracefully
      }
    } catch (e) {
      print('⚠️ [CSE LOGOUT LOG] network error: $e');
      return; // skip clearing prefs if you want guaranteed server confirmation
    }
  }
}
