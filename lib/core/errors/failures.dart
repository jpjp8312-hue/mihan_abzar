/// خانواده خطاهای Domain. UI فقط [messageFa] را نمایش می‌دهد، هرگز Stack Trace.
///
/// این کلاس‌ها معادل «قانون بخش ۱۱۶» هستند: هر خطای Domain باید به پیام
/// فارسی روشن ترجمه شود، نه پرتاب Exception خام به کاربر.
sealed class Failure {
  final String messageFa;
  final String code;
  const Failure({required this.messageFa, required this.code});
}

class InsufficientStockFailure extends Failure {
  const InsufficientStockFailure()
      : super(code: 'STOCK_INSUFFICIENT', messageFa: 'موجودی کافی نیست.');
}

class AssetAlreadyRentedFailure extends Failure {
  const AssetAlreadyRentedFailure()
      : super(
          code: 'ASSET_ALREADY_RENTED',
          messageFa: 'این ابزار در حال حاضر اجاره داده شده است.',
        );
}

class PartNotReceivedFailure extends Failure {
  const PartNotReceivedFailure()
      : super(code: 'PART_NOT_RECEIVED', messageFa: 'قطعه هنوز دریافت نشده است.');
}

class PermissionDeniedFailure extends Failure {
  const PermissionDeniedFailure([String? permissionKey])
      : super(
          code: 'PERMISSION_DENIED',
          messageFa: 'این عملیات نیاز به دسترسی مدیر دارد.',
        );
}

class ValidationFailure extends Failure {
  const ValidationFailure(String messageFa)
      : super(code: 'VALIDATION_ERROR', messageFa: messageFa);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(String entityNameFa)
      : super(code: 'NOT_FOUND', messageFa: '$entityNameFa یافت نشد.');
}

class ConcurrencyFailure extends Failure {
  const ConcurrencyFailure()
      : super(
          code: 'CONCURRENCY_CONFLICT',
          messageFa: 'این رکورد همزمان توسط عملیات دیگری تغییر کرده است.',
        );
}

class DatabaseFailure extends Failure {
  final Object? cause;
  const DatabaseFailure([this.cause])
      : super(code: 'DB_ERROR', messageFa: 'خطا در ذخیره‌سازی اطلاعات رخ داد.');
}

class UnknownFailure extends Failure {
  final Object? cause;
  const UnknownFailure([this.cause])
      : super(code: 'UNKNOWN', messageFa: 'خطای غیرمنتظره رخ داد.');
}
