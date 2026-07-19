import 'package:falta_app/core/pref/shared_pref_controller.dart';
import 'package:falta_app/features/home/data/repositories/home_repository_impl.dart';
import 'package:falta_app/features/home/domain/entities/home_entity.dart';
import 'package:falta_app/features/home/domain/repositories/home_repository.dart';
import 'package:falta_app/features/home/domain/usecases/get_home.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ── Repository ────────────────────────────────────────────────────────────
final homeRepositoryProvider = Provider<HomeRepository>(
      (ref) => const HomeRepositoryImpl(),
);

/// ── Home dashboard ────────────────────────────────────────────────────────
///
/// Replaces `FetchHomeDashboardRequested` / `HomeFetchSuccess` /
/// `HomeFailure` from the old [HomeBloc]. `home_body_screen.dart` watches
/// this directly with `ref.watch(homeDashboardProvider)` — no manual
/// `context.read<HomeBloc>().add(...)` dispatch needed on `initState`,
/// since `build()` runs automatically the first time the provider is read.
final homeDashboardProvider =
AsyncNotifierProvider<HomeDashboardNotifier, HomeEntity>(
  HomeDashboardNotifier.new,
);

class HomeDashboardNotifier extends AsyncNotifier<HomeEntity> {
  @override
  Future<HomeEntity> build() => _fetch();

  Future<HomeEntity> _fetch() async {
    final token = SharedPrefController().accessToken;

    if (token.isEmpty) {
      throw const HomeApiException('يجب تسجيل الدخول أولاً');
    }

    return GetHome(ref.read(homeRepositoryProvider))(token: token);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}