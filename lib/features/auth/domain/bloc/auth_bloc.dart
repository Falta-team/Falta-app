import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:falta_app/core/pref/shared_pref_controller.dart';
import 'package:falta_app/features/auth/data/auth_api_controller.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthApiController _api;
  final SharedPrefController _pref = SharedPrefController();

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

    if (!_pref.isLoggedIn || _pref.refreshToken.isEmpty) {
      emit(const NotAuthenticatedState());
      return;
    }

    // جرّب تجدد التوكن
    final result = await _api.refreshToken(refreshToken: _pref.refreshToken);

    if (result.success && result.data != null) {
      // ⚠️ endpoint الـ refresh-token ممكن يرجّع فقط accessToken جديد
      // من دون refreshToken/user (شي شائع بالـ APIs يلي بتعمل rotation
      // بس مش بكل مرة). إذا رجعوا فاضيين، لازم نحافظ على القيم القديمة
      // بدل ما نمسحها فوق بعضها بقيمة فاضية.
      final newRefreshToken = result.data!.refreshToken.isNotEmpty
          ? result.data!.refreshToken
          : _pref.refreshToken;
      final newUser =
      result.data!.user.isNotEmpty ? result.data!.user : _pref.toUserMap();

      await _pref.saveSession(
        accessToken:  result.data!.accessToken,
        refreshToken: newRefreshToken,
        user:         newUser,
      );
      emit(AlreadyAuthenticatedState(AuthTokens(
        accessToken:  result.data!.accessToken,
        refreshToken: newRefreshToken,
        user:         newUser,
      )));
    } else {
      await _pref.clear();
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
      // ✅ احفظ كل البيانات مرة وحدة
      await _pref.saveSession(
        accessToken:  result.data!.accessToken,
        refreshToken: result.data!.refreshToken,
        user:         result.data!.user,
      );
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
    final result = await _api.forgotPassword(phoneNumber: event.phoneNumber);
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
    if (result.success) {
      emit(VerifyOtpSuccessState(
        phoneNumber: event.phoneNumber,
        code:        event.code,
        flowType:    event.flowType,
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
    await _api.logout(
      accessToken:  _pref.accessToken,
      refreshToken: _pref.refreshToken,
    );
    await _pref.clear();
    emit(const LogoutSuccessState());
  }

  // ── Public getter (backward compat) ──────────────────────────────────────
  Future<String?> getAccessToken() async => _pref.accessToken.isEmpty
      ? null
      : _pref.accessToken;
}