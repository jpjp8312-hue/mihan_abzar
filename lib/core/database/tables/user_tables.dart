import 'package:drift/drift.dart';

/// کاربران سیستم (بخش ۷۵–۷۶).
/// PIN/Password هرگز Plain Text ذخیره نمی‌شود — فقط Hash امن (bcrypt/argon2 wrapper
/// در core/security/pin_hasher.dart).
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get fullName => text().withLength(min: 1, max: 120)();
  TextColumn get username => text().withLength(min: 3, max: 60).unique()();
  TextColumn get pinHash => text()();
  TextColumn get pinSalt => text()();

  /// نقش کلی برای دسترسی سریع (Owner/Manager/Cashier/Technician/...)؛
  /// اما Permission واقعی از جدول UserPermissions خوانده می‌شود — نقش صرفاً
  /// یک Preset پیش‌فرض است، نه منبع حقیقت دسترسی (بخش ۷۷–۷۸).
  TextColumn get role => text().withLength(min: 1, max: 40)();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  /// برای آمادگی Sync آینده (بخش ۱۰۲).
  TextColumn get syncId => text().nullable()();
}

/// فهرست کامل Permission Keyهای granular سیستم (بخش ۷۷).
/// این جدول Seed می‌شود و به‌ندرت توسط کاربر تغییر می‌کند؛ صرفاً کاتالوگ است.
class Permissions extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// مثال: sales.create, rental.damage, repair.approve_cost
  TextColumn get key => text().withLength(min: 3, max: 80).unique()();
  TextColumn get descriptionFa => text()();
  TextColumn get moduleFa => text()(); // گروه‌بندی نمایشی: فروش/اجاره/تعمیر/...
}

/// نگاشت کاربر ↔ Permission (Many-to-Many). این جدول منبع حقیقت مجوزهاست،
/// نه فقط مخفی‌کردن دکمه در UI (بخش ۷۸: Enforcement باید در UI *و* Use Case باشد).
class UserPermissions extends Table {
  IntColumn get userId =>
      integer().references(Users, #id, onDelete: KeyAction.cascade)();
  IntColumn get permissionId =>
      integer().references(Permissions, #id, onDelete: KeyAction.cascade)();
  BoolColumn get granted => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {userId, permissionId};
}

/// ثبت تمام عملیات حساس سیستم (بخش ۱۰۶–۱۰۷). این جدول Append-only است؛
/// هیچ Feature حق UPDATE/DELETE روی آن ندارد.
class AuditLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().nullable().references(Users, #id)();

  /// مثال: SALE_CREATE, PERMISSION_CHANGE, RENTAL_FORM_GENERATED
  TextColumn get action => text().withLength(min: 1, max: 60)();

  /// مثال: Invoice, Asset, RepairOrder
  TextColumn get entityType => text().withLength(min: 1, max: 60)();
  TextColumn get entityId => text()();

  /// جزئیات ساختاریافته (JSON) — هرگز شامل تصویر مدرک هویتی نمی‌شود (بخش ۴۵).
  TextColumn get detailsJson => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
