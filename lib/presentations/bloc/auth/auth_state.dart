import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

// Initial state
class AuthInitial extends AuthState {}

// Loading state
class AuthLoading extends AuthState {}

// Authenticated state
class Authenticated extends AuthState {
  final User user;

  const Authenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

// Unauthenticated state
class Unauthenticated extends AuthState {}

// Auth error state
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Password reset sent
class PasswordResetSent extends AuthState {
  final String email;

  const PasswordResetSent({required this.email});

  @override
  List<Object?> get props => [email];
}