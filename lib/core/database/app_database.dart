import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

import 'tables/user_tables.dart';

part 'app_database.g.dart';

/// نسخه فعلی Schema. هر تغییر ساختاری باید این عدد را افزایش دهد و
/// Migration متناظر را در [_migration] اضافه کند (بخش ۱۲۰).
const int kSchemaVersion = 1;

@DriftDatabase(tables: [
  Users,
  Permissions,
  UserPermissions,
  AuditLogs,
  // Phase 2 به بعد: Categories, Units, Products, Parties, Assets, ...
  // هر جدول جدید باید اینجا و در MigrationStrategy ثبت شود.
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => kSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          await _enableForeignKeys(this);
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // مثال آینده:
          // if (from < 2) { await m.addColumn(...); }
          // داده قبلی هرگز نباید بدون برنامه از بین برود (بخش ۱۲۰).
        },
        beforeOpen: (details) async {
          await _enableForeignKeys(this);
        },
      );

  static Future<void> _enableForeignKeys(AppDatabase db) async {
    // SQLite Foreign Keys باید فعال باشند (بخش ۱۱، ۱۱۹).
    await db.customStatement('PRAGMA foreign_keys = ON;');
  }
}

/// اتصال به فایل SQLite محلی روی دستگاه (Offline-first — بخش ۲، ۹۰).
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'mihan_abzar.sqlite'));

    // در اندروید از Native SQLite کتابخانه‌ی سازگار استفاده می‌شود.
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }
    final cachebase = (await getTemporaryDirectory()).path;
    sqlite3.tempDirectory = cachebase;

    return NativeDatabase.createInBackground(file);
  });
}
