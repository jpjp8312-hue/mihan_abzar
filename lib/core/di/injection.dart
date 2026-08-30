import 'package:get_it/get_it.dart';
import 'package:mihan_abzar/core/audit/audit_service.dart';
import 'package:mihan_abzar/core/database/app_database.dart';
import 'package:mihan_abzar/core/permissions/permission_service.dart';
import 'package:mihan_abzar/core/security/default_user_seeder.dart';
import 'package:mihan_abzar/core/security/pin_hasher.dart';
import 'package:mihan_abzar/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mihan_abzar/features/auth/domain/repositories/auth_repository.dart';
import 'package:mihan_abzar/features/auth/domain/usecases/login_use_case.dart';

final GetIt sl = GetIt.instance;

/// ثبت مرکزی و قابل‌تست تمام وابستگی‌ها. تست‌ها می‌توانند نمونه‌های Fake را
/// جایگزین این Registrationها کنند (بخش ۶: DI مرکزی و قابل تست).
///
/// **الگو**: هر Feature جدید (Phase 2 به بعد) بخش خودش را در یک تابع
/// `_registerXxxFeature(sl)` جداگانه اضافه می‌کند تا این فایل شلوغ نشود.
Future<void> configureDependencies({AppDatabase? testDatabase}) async {
  // ---- Core ----
  sl.registerLazySingleton<AppDatabase>(() => testDatabase ?? AppDatabase());
  sl.registerLazySingleton<PinHasher>(() => PinHasher());
  sl.registerLazySingleton<AuditService>(() => AuditService(sl<AppDatabase>()));
  sl.registerLazySingleton<PermissionService>(
    () => PermissionService(sl<AppDatabase>()),
  );
  sl.registerLazySingleton<DefaultUserSeeder>(
    () => DefaultUserSeeder(sl<AppDatabase>(), sl<PinHasher>(), sl<AuditService>()),
  );

  // ---- Feature: Auth ----
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AppDatabase>(), sl<PinHasher>()),
  );
  sl.registerFactory<LoginUseCase>(
    () => LoginUseCase(sl<AuthRepository>(), sl<AuditService>()),
  );

  // Phase 2 به بعد اینجا اضافه می‌شود:
  // _registerProductsFeature(sl);
  // _registerPartiesFeature(sl);
  // ...
}

/// برای تست‌ها: بازنشانی کامل Container بین تست‌ها.
Future<void> resetDependencies() async {
  await sl.reset();
}
