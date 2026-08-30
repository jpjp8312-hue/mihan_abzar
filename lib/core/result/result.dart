import 'package:mihan_abzar/core/errors/failures.dart';

/// نوع نتیجه استاندارد برای تمام لایه‌های Domain/Application.
///
/// هیچ Use Case یا Repository نباید Exception خام را مستقیماً به لایه بالاتر
/// پرتاب کند؛ همه باید [Result] برگردانند تا:
///  - خطاها به پیام فارسی قابل‌فهم تبدیل شوند (بخش ۱۱۶)
///  - UI هرگز Stack Trace نبیند
///  - منطق موفق/ناموفق به‌صورت type-safe بررسی شود
sealed class Result<T> {
  const Result();

  const factory Result.success(T value) = Success<T>;
  const factory Result.failure(Failure failure) = ResultFailure<T>;

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is ResultFailure<T>;

  /// دسترسی امن به مقدار موفق؛ اگر Failure باشد null برمی‌گرداند.
  T? get valueOrNull => switch (this) {
        Success<T>(value: final v) => v,
        ResultFailure<T>() => null,
      };

  Failure? get failureOrNull => switch (this) {
        Success<T>() => null,
        ResultFailure<T>(failure: final f) => f,
      };

  /// الگوی fold برای پردازش هر دو حالت بدون if/else پراکنده.
  R fold<R>(R Function(Failure failure) onFailure, R Function(T value) onSuccess) {
    return switch (this) {
      Success<T>(value: final v) => onSuccess(v),
      ResultFailure<T>(failure: final f) => onFailure(f),
    };
  }

  Result<R> map<R>(R Function(T value) transform) {
    return switch (this) {
      Success<T>(value: final v) => Result.success(transform(v)),
      ResultFailure<T>(failure: final f) => Result.failure(f),
    };
  }
}

final class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

final class ResultFailure<T> extends Result<T> {
  final Failure failure;
  const ResultFailure(this.failure);
}
