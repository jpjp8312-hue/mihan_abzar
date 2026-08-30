import 'package:mihan_abzar/core/audit/audit_service.dart';
import 'package:mihan_abzar/core/result/result.dart';
import 'package:mihan_abzar/features/auth/domain/entities/app_user.dart';
import 'package:mihan_abzar/features/auth/domain/repositories/auth_repository.dart';

/// ورود کاربر با نام‌کاربری/PIN. طبق بخش ۱۰۷ باید Login حتماً Audit شود
/// (چه موفق چه ناموفق) تا امکان بررسی امنیتی بعدی وجود داشته باشد.
class LoginUseCase {
  final AuthRepository _authRepository;
  final AuditService _auditService;

  LoginUseCase(this._authRepository, this._auditService);

  Future<Result<AppUser>> call({required String username, required String pin}) async {
    final result = await _authRepository.login(username: username, pin: pin);

    await result.fold(
      (failure) => _auditService.log(
        userId: null,
        action: AuditActions.login,
        entityType: 'User',
        entityId: username,
        details: {'success': false, 'reason': failure.code},
      ),
      (user) => _auditService.log(
        userId: user.id,
        action: AuditActions.login,
        entityType: 'User',
        entityId: user.id.toString(),
        details: {'success': true},
      ),
    );

    return result;
  }
}
