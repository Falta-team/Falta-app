part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

// ── Initial ───────────────────────────────────────────────────────────────────
class AuthInitialState extends AuthState {
  const AuthInitialState();
}

// ── Loading ───────────────────────────────────────────────────────────────────
class AuthLoadingState extends AuthState {
  const AuthLoadingState();
}

// ── Login ─────────────────────────────────────────────────────────────────────
class LoginSuccessState extends AuthState {
  final AuthTokens tokens;

  const LoginSuccessState(this.tokens);

  @override
  List<Object?> get props => [tokens.accessToken];
}

class LoginFailureState extends AuthState {
  final String message;

  const LoginFailureState(this.message);

  @override
  List<Object?> get props => [message];
}

// ── Register ──────────────────────────────────────────────────────────────────
class RegisterSuccessState extends AuthState {
  final String phoneNumber; // carry phone to OTP screen
  const RegisterSuccessState(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

class RegisterFailureState extends AuthState {
  final String message;

  const RegisterFailureState(this.message);

  @override
  List<Object?> get props => [message];
}

// ── Forgot Password ───────────────────────────────────────────────────────────
class ForgotPasswordSuccessState extends AuthState {
  final String phoneNumber; // carry phone to OTP screen
  const ForgotPasswordSuccessState(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

class ForgotPasswordFailureState extends AuthState {
  final String message;

  const ForgotPasswordFailureState(this.message);

  @override
  List<Object?> get props => [message];
}

// ── Verify OTP ────────────────────────────────────────────────────────────────
class VerifyOtpSuccessState extends AuthState {
  final String phoneNumber;
  final String code;        // carry code to ResetPassword screen

  const VerifyOtpSuccessState({
    required this.phoneNumber,
    required this.code,
  });

  @override
  List<Object?> get props => [phoneNumber, code];
}

class VerifyOtpFailureState extends AuthState {
  final String message;

  const VerifyOtpFailureState(this.message);

  @override
  List<Object?> get props => [message];
}

// ── Reset Password ────────────────────────────────────────────────────────────
class ResetPasswordSuccessState extends AuthState {
  const ResetPasswordSuccessState();
}

class ResetPasswordFailureState extends AuthState {
  final String message;

  const ResetPasswordFailureState(this.message);

  @override
  List<Object?> get props => [message];
}

// ── Logout ────────────────────────────────────────────────────────────────────
class LogoutSuccessState extends AuthState {
  const LogoutSuccessState();
}

// ── Already Authenticated (on app start) ─────────────────────────────────────
class AlreadyAuthenticatedState extends AuthState {
  final AuthTokens tokens;
  const AlreadyAuthenticatedState(this.tokens);

  @override
  List<Object?> get props => [tokens.accessToken];
}

class NotAuthenticatedState extends AuthState {
  const NotAuthenticatedState();
}