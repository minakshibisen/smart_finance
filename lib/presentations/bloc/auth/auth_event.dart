import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

// Check auth status
class CheckAuthStatusEvent extends AuthEvent {}

// Login with email
class LoginWithEmailEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginWithEmailEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

// Register with email
class RegisterWithEmailEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;

  const RegisterWithEmailEvent({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email, password];
}

// Login with Google
class LoginWithGoogleEvent extends AuthEvent {}

// Logout
class LogoutEvent extends AuthEvent {}

// Reset password
class ResetPasswordEvent extends AuthEvent {
  final String email;

  const ResetPasswordEvent({required this.email});

  @override
  List<Object?> get props => [email];
}