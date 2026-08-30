import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mihan_abzar/core/database/app_database.dart';
import 'package:mihan_abzar/core/di/injection.dart';
import 'package:mihan_abzar/core/permissions/permission_seeder.dart';
import 'package:mihan_abzar/core/security/default_user_seeder.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await configureDependencies();

  // ترتیب حیاتی است: کاتالوگ Permission باید قبل از ساخت کاربر پیش‌فرض
  // Seed شود، وگرنه OWNER پیش‌فرض هیچ Permissionای دریافت نمی‌کند.
  await PermissionSeeder(sl<AppDatabase>()).seed();
  await sl<DefaultUserSeeder>().seedIfEmpty();

  runApp(const ProviderScope(child: MihanAbzarApp()));
}

class MihanAbzarApp extends StatelessWidget {
  const MihanAbzarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'میهن ابزار',
      locale: const Locale('fa', 'IR'),
      supportedLocales: const [Locale('fa', 'IR')],
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      builder: (context, child) {
        // RTL اجباری برای کل برنامه (بخش ۸۹).
        return Directionality(textDirection: TextDirection.rtl, child: child!);
      },
      home: const _Phase1PlaceholderHome(),
    );
  }
}

/// این صفحه صرفاً نشان‌دهنده اتصال موفق DI/Database/Seeding در Phase 1 است.
/// صفحه واقعی Login و Dashboard در Phase 1 (auth UI) و Phase 4 (dashboard
/// نهایی طبق بخش ۷۹) تکمیل می‌شود.
class _Phase1PlaceholderHome extends StatelessWidget {
  const _Phase1PlaceholderHome();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('میهن ابزار — Phase 1')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'زیرساخت پایه (Database, DI, Security, Permission, Audit, Migration) '
            'با موفقیت راه‌اندازی شد.\nمرحله بعد: Master Data (Phase 2).',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
