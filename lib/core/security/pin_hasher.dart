import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

/// Hash امن PIN/Password. هرگز مقدار Plain Text ذخیره نشود (بخش ۷۶).
///
/// نکته پیاده‌سازی: PBKDF2 دستی با HMAC-SHA256 و Salt تصادفی برای هر کاربر.
/// (در نسخه Production می‌توان به bcrypt/argon2 native package مهاجرت کرد؛
/// امضای این کلاس طوری طراحی شده که تعویض الگوریتم بدون تغییر Caller ممکن باشد.)
class PinHasher {
  static const int _iterations = 100000;
  static const int _keyLength = 32; // bytes

  /// Salt تصادفی جدید برای هر کاربر (Base64).
  String generateSalt() {
    final rand = Random.secure();
    final bytes = List<int>.generate(16, (_) => rand.nextInt(256));
    return base64Url.encode(bytes);
  }

  /// Hash کردن PIN با Salt مشخص. خروجی Base64.
  String hash(String pin, String salt) {
    final saltBytes = base64Url.decode(salt);
    var derived = utf8.encode(pin) + saltBytes;
    for (var i = 0; i < _iterations; i++) {
      derived = Hmac(sha256, saltBytes).convert(derived).bytes;
    }
    return base64Url.encode(derived.take(_keyLength).toList());
  }

  /// مقایسه امن (constant-time) بین Hash ذخیره‌شده و PIN وارد شده.
  bool verify(String pin, String salt, String expectedHash) {
    final computed = hash(pin, salt);
    return _constantTimeEquals(computed, expectedHash);
  }

  bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }
}
