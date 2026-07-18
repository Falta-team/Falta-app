part of 'auth_bloc.dart';
enum OtpFlowType { register, forgotPassword }
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

// ── Login ────────────────────────────────────────────────────────────────────
class LoginEvent extends AuthEvent {
  final String phoneNumber;
  final String password;


  const LoginEvent({
    required this.phoneNumber,
    required this.password,
  });

  @override
  List<Object?> get props => [phoneNumber, password];
}

// ── Register ─────────────────────────────────────────────────────────────────
class RegisterEvent extends AuthEvent {
  final String phoneNumber;
  final String firstName;
  final String lastName;
  final String password;
  final String academicBranch;

  const RegisterEvent({
    required this.phoneNumber,
    required this.firstName,
    required this.lastName,
    required this.password,
    required this.academicBranch,
  });

  @override
  List<Object?> get props => [phoneNumber, firstName, lastName, academicBranch];
}

// ── Forgot Password ───────────────────────────────────────────────────────────
class ForgotPasswordEvent extends AuthEvent {
  final String phoneNumber;

  const ForgotPasswordEvent({required this.phoneNumber});

  @override
  List<Object?> get props => [phoneNumber];
}

// ── Verify OTP ────────────────────────────────────────────────────────────────
class VerifyOtpEvent extends AuthEvent {
  final String phoneNumber;
  final String code;
  final OtpFlowType flowType;  // ← أضف هاد

  const VerifyOtpEvent({
    required this.phoneNumber,
    required this.code, required this.flowType,
  });

  @override
  List<Object?> get props => [phoneNumber, code,flowType];

}

// ── Reset Password ────────────────────────────────────────────────────────────
class ResetPasswordEvent extends AuthEvent {
  final String phoneNumber;
  final String code;
  final String newPassword;

  const ResetPasswordEvent({
    required this.phoneNumber,
    required this.code,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [phoneNumber, code];
}

// ── Logout ────────────────────────────────────────────────────────────────────
class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

// ── Check Auth (on app start) ─────────────────────────────────────────────────
class CheckAuthEvent extends AuthEvent {
  const CheckAuthEvent();
}