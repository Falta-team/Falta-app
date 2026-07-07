import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:falta_app/features/auth/data/auth_api_controller.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthApiController _api;

  // SharedPreferences keys
  static const String _keyAccessToken  = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserData     = 'user_data';

  AuthBloc({AuthApiController? api})
      : _api = api ?? AuthApiController(),
        super(const AuthInitialState()) {
    on<CheckAuthEvent>(_onCheckAuth);
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<ForgotPasswordEvent>(_onForgotPassword);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<ResetPasswordEvent>(_onResetPassword);
    on<LogoutEvent>(_onLogout);
  }

  // ── Check Auth on App Start ──────────────────────────────────────────────
  Future<void> _onCheckAuth(
      CheckAuthEvent event, Emitter<AuthState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken  = prefs.getString(_keyAccessToken);
    final refreshToken = prefs.getString(_keyRefreshToken);

    if (accessToken == null || refreshToken == null) {
      emit(const NotAuthenticatedState());
      return;
    }

    // Try refreshing the token to validate session
    final result = await _api.refreshToken(refreshToken: refreshToken);

    if (result.success && result.data != null) {
      await _saveTokens(result.data!);
      emit(AlreadyAuthenticatedState(result.data!));
    } else {
      await _clearTokens();
      emit(const NotAuthenticatedState());
    }
  }

  // ── Login ────────────────────────────────────────────────────────────────
  Future<void> _onLogin(
      LoginEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoadingState());

    final result = await _api.login(
      phoneNumber: event.phoneNumber,
      password:    event.password,
    );

    if (result.success && result.data != null) {
      await _saveTokens(result.data!);
      emit(LoginSuccessState(result.data!));
    } else {
      emit(LoginFailureState(result.error ?? 'حدث خطأ غير متوقع'));
    }
  }

  // ── Register ─────────────────────────────────────────────────────────────
  Future<void> _onRegister(
      RegisterEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoadingState());

    final result = await _api.register(
      phoneNumber:    event.phoneNumber,
      firstName:      event.firstName,
      lastName:       event.lastName,
      password:       event.password,
      academicBranch: event.academicBranch,
    );

    if (result.success) {
      emit(RegisterSuccessState(event.phoneNumber));
    } else {
      emit(RegisterFailureState(result.error ?? 'حدث خطأ غير متوقع'));
    }
  }

  // ── Forgot Password ──────────────────────────────────────────────────────
  Future<void> _onForgotPassword(
      ForgotPasswordEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoadingState());

    final result = await _api.forgotPassword(
      phoneNumber: event.phoneNumber,
    );

    if (result.success) {
      emit(ForgotPasswordSuccessState(event.phoneNumber));
    } else {
      emit(ForgotPasswordFailureState(result.error ?? 'حدث خطأ غير متوقع'));
    }
  }

  // ── Verify OTP ───────────────────────────────────────────────────────────
  Future<void> _onVerifyOtp(
      VerifyOtpEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoadingState());

    final result = await _api.verifyOtp(
      phoneNumber: event.phoneNumber,
      code:        event.code,
    );
    print(event.code);
    if (result.success) {
      emit(VerifyOtpSuccessState(
        phoneNumber: event.phoneNumber,
        code:        event.code,
      ));
    } else {
      emit(VerifyOtpFailureState(result.error ?? 'الرمز غير صحيح'));
    }
  }

  // ── Reset Password ───────────────────────────────────────────────────────
  Future<void> _onResetPassword(
      ResetPasswordEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoadingState());

    final result = await _api.resetPassword(
      phoneNumber: event.phoneNumber,
      code:        event.code,
      newPassword: event.newPassword,
    );

    if (result.success) {
      emit(const ResetPasswordSuccessState());
    } else {
      emit(ResetPasswordFailureState(result.error ?? 'حدث خطأ غير متوقع'));
    }
  }

  // ── Logout ───────────────────────────────────────────────────────────────
  Future<void> _onLogout(
      LogoutEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoadingState());

    final prefs        = await SharedPreferences.getInstance();
    final accessToken  = prefs.getString(_keyAccessToken)  ?? '';
    final refreshToken = prefs.getString(_keyRefreshToken) ?? '';

    await _api.logout(
      refreshToken: refreshToken,
      accessToken:  accessToken,
    );

    await _clearTokens();
    emit(const LogoutSuccessState());
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Future<void> _saveTokens(AuthTokens tokens) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAccessToken,  tokens.accessToken);
    await prefs.setString(_keyRefreshToken, tokens.refreshToken);
  }

  Future<void> _clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
    await prefs.remove(_keyUserData);
  }

  // ── Public getter for access token (used in other BLoCs) ─────────────────
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAccessToken);
  }
}