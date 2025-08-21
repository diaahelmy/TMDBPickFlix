
import '../../../models/user_model.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

/// Login States
class AuthLoginLoading extends AuthState {}
class AuthLoginSuccess extends AuthState {
  final UserModel user;
  AuthLoginSuccess(this.user);
}
class AuthLoginError extends AuthState {
  final String error;
  AuthLoginError(this.error);
}

/// Register States
class AuthRegisterLoading extends AuthState {}
class AuthRegisterSuccess extends AuthState {
  final UserModel user;
  AuthRegisterSuccess(this.user);
}
class AuthRegisterError extends AuthState {
  final String error;
  AuthRegisterError(this.error);
}
