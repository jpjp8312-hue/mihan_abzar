import 'package:mihan_abzar/core/result/result.dart';
import 'package:mihan_abzar/features/auth/domain/entities/app_user.dart';

/// قرارداد Domain برای احراز هویت. پیاده‌سازی واقعی (Drift) در
/// data/repositories قرار می‌گیرد؛ UI و Use Caseها فقط این Interface را
/// می‌شناسند (بخش ۷: UI نباید مستقیماً DAO را صدا بزند).
abstract interface class AuthRepository {
  Future<Result<AppUser>> login({required String username, required String pin});
  Future<Result<AppUser>> getCurrentUser(int userId);
  Future<Result<void>> logout(int userId);
}
