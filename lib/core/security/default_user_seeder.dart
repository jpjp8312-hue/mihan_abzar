import 'package:drift/drift.dart';
import 'package:mihan_abzar/core/audit/audit_service.dart';
import 'package:mihan_abzar/core/database/app_database.dart';
import 'package:mihan_abzar/core/security/pin_hasher.dart';

/// در اولین اجرای برنامه (وقتی جدول Users کاملاً خالی است)، یک کاربر
/// پیش‌فرض OWNER می‌سازد تا کاربر بتواند وارد شود و بعداً از طریق Settings
/// آن را تغییر دهد یا کاربران جدید بسازد.
///
/// **این Seeder فقط زمانی اجرا می‌شود که هیچ کاربری در دیتابیس نباشد** —
/// یعنی هرگز کاربر موجود را بازنویسی یا تکرار نمی‌کند (Idempotent).
///
/// طبق بخش ۷۶: رمز هرگز Plain Text ذخیره نمی‌شود — از همان [PinHasher]
/// استاندارد (Salt تصادفی + PBKDF2/HMAC-SHA256) استفاده می‌شود.
/// طبق بخش ۱۰۷: ایجاد این کاربر هم یک User Change است و Audit می‌شود.
class DefaultUserSeeder {
  static const String defaultUsername = 'admin';
  static const String defaultPin = '1234';
  static const String defaultRole = 'OWNER';

  final AppDatabase _db;
  final PinHasher _pinHasher;
  final AuditService _auditService;

  DefaultUserSeeder(this._db, this._pinHasher, this._auditService);

  /// اگر هیچ کاربری وجود نداشت، کاربر پیش‌فرض OWNER با تمام Permissionها
  /// می‌سازد. در غیر این صورت کاری انجام نمی‌دهد.
  Future<void> seedIfEmpty() async {
    final existingCount = await _db.select(_db.users).get().then((r) => r.length);
    if (existingCount > 0) return; // فقط اولین اجرا

    await _db.transaction(() async {
      final salt = _pinHasher.generateSalt();
      final hash = _pinHasher.hash(defaultPin, salt);

      final userId = await _db.into(_db.users).insert(
            UsersCompanion.insert(
              fullName: 'مدیر کل',
              username: defaultUsername,
              pinHash: hash,
              pinSalt: salt,
              role: defaultRole,
            ),
          );

      // OWNER در اولین اجرا تمام Permissionهای موجود را می‌گیرد (بخش ۷۷).
      // این‌ها باید از قبل توسط PermissionSeeder ساخته شده باشند؛ اگر
      // PermissionSeeder هنوز اجرا نشده، این حلقه چیزی پیدا نمی‌کند و
      // خالی برمی‌گردد (به همین دلیل ترتیب فراخوانی در main.dart مهم است:
      // PermissionSeeder باید همیشه قبل از DefaultUserSeeder اجرا شود).
      final allPermissions = await _db.select(_db.permissions).get();
      for (final perm in allPermissions) {
        await _db.into(_db.userPermissions).insert(
              UserPermissionsCompanion.insert(
                userId: userId,
                permissionId: perm.id,
                granted: const Value(true),
              ),
            );
      }

      await _auditService.log(
        userId: userId,
        action: AuditActions.userChange,
        entityType: 'User',
        entityId: userId.toString(),
        details: {
          'event': 'DEFAULT_OWNER_CREATED',
          'username': defaultUsername,
          // هرگز رمز یا Hash آن در Audit ثبت نمی‌شود.
        },
      );
    });
  }
}
