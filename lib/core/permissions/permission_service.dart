import 'package:drift/drift.dart';
import 'package:mihan_abzar/core/database/app_database.dart';
import 'package:mihan_abzar/core/errors/failures.dart';
import 'package:mihan_abzar/core/result/result.dart';

/// سرویس مرکزی بررسی دسترسی. **هر Use Case حساس باید قبل از اجرای عملیات
/// این سرویس را صدا بزند** — مخفی‌کردن دکمه در UI به‌تنهایی کافی نیست
/// (بخش ۷۸). این یعنی حتی اگر کاربری با ابزار جانبی مستقیماً Use Case را
/// صدا بزند (مثلاً از طریق دیباگ)، باز هم دسترسی enforce می‌شود.
class PermissionService {
  final AppDatabase _db;

  PermissionService(this._db);

  /// بررسی می‌کند کاربر مشخص‌شده مجوز [permissionKey] را دارد یا خیر.
  Future<bool> hasPermission({
    required int userId,
    required String permissionKey,
  }) async {
    final query = _db.select(_db.userPermissions).join([
      innerJoin(
        _db.permissions,
        _db.permissions.id.equalsExp(_db.userPermissions.permissionId),
      ),
    ])
      ..where(_db.userPermissions.userId.equals(userId))
      ..where(_db.permissions.key.equals(permissionKey))
      ..where(_db.userPermissions.granted.equals(true));

    final row = await query.getSingleOrNull();
    return row != null;
  }

  /// Helper برای Use Caseها: اگر مجوز نبود [PermissionDeniedFailure] برمی‌گرداند.
  /// الگوی استفاده در هر Use Case:
  ///
  /// ```dart
  /// final check = await permissionService.require(
  ///   userId: userId, permissionKey: PermissionKeys.salesCreate);
  /// if (check != null) return Result.failure(check);
  /// ```
  Future<Failure?> require({
    required int userId,
    required String permissionKey,
  }) async {
    final allowed = await hasPermission(userId: userId, permissionKey: permissionKey);
    if (!allowed) return PermissionDeniedFailure(permissionKey);
    return null;
  }
}
