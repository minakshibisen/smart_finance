import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/remote/firebase_service/firebase_auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuthService _authService;

  AuthBloc({required FirebaseAuthService authService})
      : _authService = authService,
        super(AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LoginWithEmailEvent>(_onLoginWithEmail);
    on<RegisterWithEmailEvent>(_onRegisterWithEmail);
    on<LoginWithGoogleEvent>(_onLoginWithGoogle);
    on<LogoutEvent>(_onLogout);
    on<ResetPasswordEvent>(_onResetPassword);
  }

  // Check auth status
  Future<void> _onCheckAuthStatus(
      CheckAuthStatusEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());

    final user = _authService.currentUser;

    if (user != null) {
      emit(Authenticated(user: user));
    } else {
      emit(Unauthenticated());
    }
  }

  // Login with email
  Future<void> _onLoginWithEmail(
      LoginWithEmailEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());

    try {
      final user = await _authService.loginWithEmail(
        email: event.email,
        password: event.password,
      );

      if (user != null) {
        emit(Authenticated(user: user));
      } else {
        emit(const AuthError(message: 'Login failed'));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  // Register with email
  Future<void> _onRegisterWithEmail(
      RegisterWithEmailEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());

    try {
      final user = await _authService.registerWithEmail(
        email: event.email,
        password: event.password,
        name: event.name,
      );

      if (user != null) {
        emit(Authenticated(user: user));
      } else {
        emit(const AuthError(message: 'Registration failed'));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  // Login with Google
  Future<void> _onLoginWithGoogle(
      LoginWithGoogleEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());

    try {
      final user = await _authService.loginWithGoogle();

      if (user != null) {
        emit(Authenticated(user: user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  // Logout
  Future<void> _onLogout(
      LogoutEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());

    try {
      await _authService.logout();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  // Reset password
  Future<void> _onResetPassword(
      ResetPasswordEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());

    try {
      await _authService.resetPassword(event.email);
      emit(PasswordResetSent(email: event.email));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
}