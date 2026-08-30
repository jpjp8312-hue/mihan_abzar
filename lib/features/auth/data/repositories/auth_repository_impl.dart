import 'package:drift/drift.dart';
import 'package:mihan_abzar/core/database/app_database.dart';
import 'package:mihan_abzar/core/errors/failures.dart';
import 'package:mihan_abzar/core/result/result.dart';
import 'package:mihan_abzar/core/security/pin_hasher.dart';
import 'package:mihan_abzar/features/auth/domain/entities/app_user.dart';
import 'package:mihan_abzar/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AppDatabase _db;
  final PinHasher _pinHasher;

  AuthRepositoryImpl(this._db, this._pinHasher);

  @override
  Future<Result<AppUser>> login({required String username, required String pin}) async {
    final userRow = await (_db.select(_db.users)
          ..where((u) => u.username.equals(username) & u.isActive.equals(true)))
        .getSingleOrNull();

    if (userRow == null) {
      return const Result.failure(ValidationFailure('نام کاربری یا رمز نادرست است.'));
    }

    final valid = _pinHasher.verify(pin, userRow.pinSalt, userRow.pinHash);
    if (!valid) {
      return const Result.failure(ValidationFailure('نام کاربری یا رمز نادرست است.'));
    }

    return Result.success(await _toEntity(userRow));
  }

  @override
  Future<Result<AppUser>> getCurrentUser(int userId) async {
    final userRow = await (_db.select(_db.users)..where((u) => u.id.equals(userId)))
        .getSingleOrNull();
    if (userRow == null) {
      return const Result.failure(NotFoundFailure('کاربر'));
    }
    return Result.success(await _toEntity(userRow));
  }

  @override
  Future<Result<void>> logout(int userId) async {
    // نسخه اول Local-only است؛ Session به‌صورت In-memory/Secure-storage در
    // لایه بالاتر مدیریت می‌شود. اینجا فقط Hook برای Audit در آینده.
    return const Result.success(null);
  }

  Future<AppUser> _toEntity(User row) async {
    final permJoin = _db.select(_db.userPermissions).join([
      innerJoin(
        _db.permissions,
        _db.permissions.id.equalsExp(_db.userPermissions.permissionId),
      ),
    ])
      ..where(_db.userPermissions.userId.equals(row.id))
      ..where(_db.userPermissions.granted.equals(true));

    final rows = await permJoin.get();
    final keys = rows.map((r) => r.readTable(_db.permissions).key).toList();

    return AppUser(
      id: row.id,
      fullName: row.fullName,
      username: row.username,
      role: row.role,
      isActive: row.isActive,
      permissionKeys: keys,
    );
  }
}
