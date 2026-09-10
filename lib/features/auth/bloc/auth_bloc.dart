import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manubhaimlt/core/errors/api_error_handler.dart';
import 'package:manubhaimlt/features/auth/data/models/firebase_log_model.dart';
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

  Future<AuthUser> _applyLoginLogContext(
    AuthUser user,
    CSEFirebaseLogResponse response,
  ) async {
    final detail = response.cseDetail;
    if (detail == null || response.successCode != 1 || response.errorCode != 0) {
      return user;
    }

    final branch = (detail['cse_mlt_branch'] ?? '').toString().trim();
    final rawLocations = detail['cse_mlt_location'];
    final locations = rawLocations is List
        ? rawLocations
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .toList()
        : <String>[];

    final updated = user.copyWith(
      cseMltBranch:
          branch.isNotEmpty ? branch : user.cseMltBranch,
      cseMltLocation:
          locations.isNotEmpty ? locations : user.cseMltLocation,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cse_mlt_branch', updated.cseMltBranch);
    await prefs.setStringList(
      'cse_mlt_location',
      List<String>.from(updated.cseMltLocation),
    );

    return updated;
  }

  Future<void> _saveSession(AuthUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cse_id', user.id);
    await prefs.setString('cse_fname', user.firstName);
    await prefs.setString('cse_lname', user.lastName);
    await prefs.setString('cse_email', user.email);
    await prefs.setString('cse_phone', user.phone);
    await prefs.setString('cse_firebase_id', user.firebaseId);
    await prefs.setString(
      'user_type',
      user.role == UserRole.cse ? 'CSE' : 'StoreKeeper',
    );
    await prefs.setString('cse_mlt_branch', user.cseMltBranch);
    await prefs.setStringList(
      'cse_mlt_location',
      List<String>.from(user.cseMltLocation),
    );
  }

  // ---------------------------------------------------------
  // APP START → check if user is already logged in (session)
  // ---------------------------------------------------------
  Future<void> _onAppStarted(
    AuthAppStarted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('cse_id');
    final firstName = prefs.getString('cse_fname');
    final lastName = prefs.getString('cse_lname');
    final email = prefs.getString('cse_email');
    final phone = prefs.getString('cse_phone');
    final roleStr = prefs.getString('user_type');
    final firebaseId = prefs.getString('cse_firebase_id');
    final savedBranch = prefs.getString('cse_mlt_branch') ?? '';
    final savedLocations =
        prefs.getStringList('cse_mlt_location') ?? const <String>[];

    if (id != null && firstName != null && roleStr != null) {
      final role =
          roleStr == 'CSE' ? UserRole.cse : UserRole.storeKeeper;

      var user = AuthUser(
        id: id,
        firstName: firstName,
        lastName: lastName ?? '',
        email: email ?? '',
        phone: phone ?? '',
        firebaseId: firebaseId ?? '',
        role: role,
        cseMltBranch: savedBranch,
        cseMltLocation: List<String>.from(savedLocations),
      );

      // Restore the authenticated session immediately so app launch keeps the
      // existing navigation flow. Branch/location saved during the previous
      // login are already available for direct search.
      emit(AuthAuthenticated(user));

      // Refresh cse_login_log.php context after restoring the session. Do not
      // hold the app in AuthLoading while waiting for this network call.
      try {
        final logResponse = await firebaseLogRepo.logLogin(
          cseId: id,
          cseFirebaseId: firebaseId ?? '',
        );
        final refreshedUser = await _applyLoginLogContext(user, logResponse);
        if (refreshedUser != user) {
          await _saveSession(refreshedUser);
          emit(AuthAuthenticated(refreshedUser));
        }
        print('📡 [CSE LOGIN LOG] sent successfully on app start');
      } catch (e) {
        print('⚠️ [CSE LOGIN LOG] failed on app start: $e');
      }
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  // ---------------------------------------------------------
  // LOGIN → call API, refresh login-log context, save session
  // ---------------------------------------------------------
  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      var user = await repository.login(
        username: event.username,
        password: event.password,
        deviceToken: event.deviceToken,
        cseDevice: event.cseDevice,
      );

      // cse_login_log.php is the canonical source for MLT branch/location.
      // Resolve it before AuthAuthenticated so a direct search can immediately
      // open Similar Products with complete CSE context.
      try {
        final logResponse = await firebaseLogRepo.logLogin(
          cseId: user.id,
          cseFirebaseId: user.firebaseId,
        );
        user = await _applyLoginLogContext(user, logResponse);
        print('📡 [CSE LOGIN LOG] sent successfully on login');
      } catch (e) {
        print('⚠️ [CSE LOGIN LOG] failed on login: $e');
      }

      await _saveSession(user);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(ApiErrorHandler.message(e)));
      emit(const AuthUnauthenticated());
    }
  }

  // ---------------------------------------------------------
  // LOGOUT → call API, clear session, and emit unauthenticated
  // ---------------------------------------------------------
  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final cseId = prefs.getString('cse_id') ?? '';
    final firebaseId = prefs.getString('cse_firebase_id') ?? '';

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
        return;
      }
    } catch (e) {
      print('⚠️ [CSE LOGOUT LOG] network error: $e');
      return;
    }
  }
}
