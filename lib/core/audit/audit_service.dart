import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:mihan_abzar/core/database/app_database.dart';

/// ثبت Append-only عملیات حساس. هیچ Feature حق UPDATE/DELETE مستقیم روی
/// AuditLogs ندارد — این کلاس تنها نقطه‌ی نوشتن است (بخش ۱۰۶–۱۰۷).
///
/// این سرویس باید **داخل همان Transaction** عملیات اصلی فراخوانی شود تا
/// Atomicity حفظ شود (بخش ۱۲: ACID) — یعنی اگر فروش Rollback شد، ثبت Audit
/// مربوط به آن هم Rollback می‌شود.
class AuditService {
  final AppDatabase _db;
  AuditService(this._db);

  Future<void> log({
    required int? userId,
    required String action,
    required String entityType,
    required String entityId,
    Map<String, dynamic>? details,
  }) async {
    // نکته بخش ۴۵: هرگز تصویر مدرک هویتی یا داده حساس دیگر در details قرار
    // نگیرد؛ فقط شناسه‌ها و متادیتای غیرحساس.
    await _db.into(_db.auditLogs).insert(
          AuditLogsCompanion.insert(
            userId: Value(userId),
            action: action,
            entityType: entityType,
            entityId: entityId,
            detailsJson: Value(details != null ? jsonEncode(details) : null),
          ),
        );
  }
}

/// نام‌های استاندارد Action برای جلوگیری از رشته‌های دستی پراکنده در کد.
abstract final class AuditActions {
  static const login = 'LOGIN';
  static const userChange = 'USER_CHANGE';
  static const permissionChange = 'PERMISSION_CHANGE';
  static const productChange = 'PRODUCT_CHANGE';
  static const priceChange = 'PRICE_CHANGE';
  static const sale = 'SALE';
  static const saleCancel = 'SALE_CANCEL';
  static const saleReturn = 'SALE_RETURN';
  static const purchase = 'PURCHASE';
  static const inventoryAdjustment = 'INVENTORY_ADJUSTMENT';
  static const rental = 'RENTAL';
  static const rentalReturn = 'RENTAL_RETURN';
  static const damage = 'DAMAGE';
  static const repair = 'REPAIR';
  static const repairCostChange = 'REPAIR_COST_CHANGE';
  static const externalService = 'EXTERNAL_SERVICE';
  static const payment = 'PAYMENT';
  static const refund = 'REFUND';
  static const usedPurchase = 'USED_PURCHASE';
  static const usedSale = 'USED_SALE';
  static const import_ = 'IMPORT';
  static const backup = 'BACKUP';
  static const restore = 'RESTORE';
  static const formGeneration = 'FORM_GENERATION';
  static const idPhotoAttachment = 'ID_PHOTO_ATTACHMENT';
  static const reprint = 'REPRINT';
}
