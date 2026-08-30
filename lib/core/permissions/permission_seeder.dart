import 'package:drift/drift.dart';
import 'package:mihan_abzar/core/database/app_database.dart';
import 'package:mihan_abzar/core/permissions/permission_keys.dart';

/// نقشه توضیح فارسی/ماژول هر Permission Key — برای نمایش در صفحه مدیریت
/// کاربران و دسترسی‌ها.
const Map<String, ({String descriptionFa, String moduleFa})> _catalog = {
  PermissionKeys.salesCreate: (descriptionFa: 'ثبت فروش جدید', moduleFa: 'فروش'),
  PermissionKeys.salesEdit: (descriptionFa: 'ویرایش فاکتور فروش', moduleFa: 'فروش'),
  PermissionKeys.salesCancel: (descriptionFa: 'لغو فاکتور فروش', moduleFa: 'فروش'),
  PermissionKeys.salesReturn: (descriptionFa: 'ثبت مرجوعی فروش', moduleFa: 'فروش'),
  PermissionKeys.purchaseCreate: (descriptionFa: 'ثبت خرید جدید', moduleFa: 'خرید'),
  PermissionKeys.purchaseEdit: (descriptionFa: 'ویرایش سند خرید', moduleFa: 'خرید'),
  PermissionKeys.inventoryView: (descriptionFa: 'مشاهده موجودی انبار', moduleFa: 'انبار'),
  PermissionKeys.inventoryAdjust: (descriptionFa: 'اصلاح دستی موجودی', moduleFa: 'انبار'),
  PermissionKeys.rentalCreate: (descriptionFa: 'ثبت اجاره جدید', moduleFa: 'اجاره'),
  PermissionKeys.rentalReturn: (descriptionFa: 'ثبت بازگشت ابزار اجاره‌ای', moduleFa: 'اجاره'),
  PermissionKeys.rentalDamage: (descriptionFa: 'ثبت خسارت ابزار اجاره‌ای', moduleFa: 'اجاره'),
  PermissionKeys.repairCreate: (descriptionFa: 'پذیرش تعمیر جدید', moduleFa: 'تعمیر'),
  PermissionKeys.repairEdit: (descriptionFa: 'ویرایش سند تعمیر', moduleFa: 'تعمیر'),
  PermissionKeys.repairApproveCost: (descriptionFa: 'تأیید هزینه اضافه تعمیر', moduleFa: 'تعمیر'),
  PermissionKeys.repairClose: (descriptionFa: 'بستن و تحویل تعمیر', moduleFa: 'تعمیر'),
  PermissionKeys.usedPurchaseCreate: (descriptionFa: 'ثبت خرید دستگاه دست‌دوم', moduleFa: 'دست‌دوم'),
  PermissionKeys.usedSaleCreate: (descriptionFa: 'ثبت فروش دستگاه دست‌دوم', moduleFa: 'دست‌دوم'),
  PermissionKeys.financeView: (descriptionFa: 'مشاهده گزارش مالی', moduleFa: 'مالی'),
  PermissionKeys.financeReceive: (descriptionFa: 'ثبت دریافت وجه', moduleFa: 'مالی'),
  PermissionKeys.financePay: (descriptionFa: 'ثبت پرداخت وجه', moduleFa: 'مالی'),
  PermissionKeys.usersManage: (descriptionFa: 'مدیریت کاربران و دسترسی‌ها', moduleFa: 'کاربران'),
  PermissionKeys.reportsView: (descriptionFa: 'مشاهده گزارشات', moduleFa: 'گزارش'),
  PermissionKeys.backupCreate: (descriptionFa: 'تهیه نسخه پشتیبان', moduleFa: 'پشتیبان‌گیری'),
  PermissionKeys.backupRestore: (descriptionFa: 'بازیابی نسخه پشتیبان', moduleFa: 'پشتیبان‌گیری'),
  PermissionKeys.importExecute: (descriptionFa: 'اجرای Import از Excel/CSV', moduleFa: 'Import'),
  PermissionKeys.hardwareManage: (descriptionFa: 'تنظیمات سخت‌افزار (پرینتر/اسکنر)', moduleFa: 'سخت‌افزار'),
};

/// در اولین اجرای برنامه، کاتالوگ Permission را در جدول Permissions
/// Insert-or-ignore می‌کند. Idempotent است — اجرای مکرر مشکلی ایجاد نمی‌کند.
class PermissionSeeder {
  final AppDatabase _db;
  PermissionSeeder(this._db);

  Future<void> seed() async {
    for (final key in PermissionKeys.all) {
      final meta = _catalog[key]!;
      await _db.into(_db.permissions).insertOnConflictUpdate(
            PermissionsCompanion.insert(
              key: key,
              descriptionFa: meta.descriptionFa,
              moduleFa: meta.moduleFa,
            ),
          );
    }
  }
}
