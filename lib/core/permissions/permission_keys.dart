/// کاتالوگ مرکزی کلیدهای Permission (بخش ۷۷). این‌ها هنگام اولین اجرا
/// در جدول Permissions Seed می‌شوند. UI و Use Caseها فقط از این ثابت‌ها
/// استفاده می‌کنند تا رشته‌های دستی و ناهماهنگ در کد پخش نشود.
abstract final class PermissionKeys {
  // فروش
  static const salesCreate = 'sales.create';
  static const salesEdit = 'sales.edit';
  static const salesCancel = 'sales.cancel';
  static const salesReturn = 'sales.return';

  // خرید
  static const purchaseCreate = 'purchase.create';
  static const purchaseEdit = 'purchase.edit';

  // انبار
  static const inventoryView = 'inventory.view';
  static const inventoryAdjust = 'inventory.adjust';

  // اجاره
  static const rentalCreate = 'rental.create';
  static const rentalReturn = 'rental.return';
  static const rentalDamage = 'rental.damage';

  // تعمیر
  static const repairCreate = 'repair.create';
  static const repairEdit = 'repair.edit';
  static const repairApproveCost = 'repair.approve_cost';
  static const repairClose = 'repair.close';

  // دستگاه دست‌دوم
  static const usedPurchaseCreate = 'used_purchase.create';
  static const usedSaleCreate = 'used_sale.create';

  // مالی
  static const financeView = 'finance.view';
  static const financeReceive = 'finance.receive';
  static const financePay = 'finance.pay';

  // کاربران
  static const usersManage = 'users.manage';

  // گزارش
  static const reportsView = 'reports.view';

  // پشتیبان‌گیری
  static const backupCreate = 'backup.create';
  static const backupRestore = 'backup.restore';

  // Import
  static const importExecute = 'import.execute';

  // سخت‌افزار
  static const hardwareManage = 'hardware.manage';

  static const List<String> all = [
    salesCreate, salesEdit, salesCancel, salesReturn,
    purchaseCreate, purchaseEdit,
    inventoryView, inventoryAdjust,
    rentalCreate, rentalReturn, rentalDamage,
    repairCreate, repairEdit, repairApproveCost, repairClose,
    usedPurchaseCreate, usedSaleCreate,
    financeView, financeReceive, financePay,
    usersManage,
    reportsView,
    backupCreate, backupRestore,
    importExecute,
    hardwareManage,
  ];
}
