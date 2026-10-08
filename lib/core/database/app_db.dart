import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDb {
  static final AppDb instance = AppDb._();
  AppDb._();
  Database? _db;

  Future<Database> get db async {
    final d = _db;
    if (d != null) return d;
    final path = join(await getDatabasesPath(), 'riwayat.db');
    _db = await openDatabase(
      path,
      version: 1,
      onConfigure: (db) =>
          db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE vehicles(
            id TEXT PRIMARY KEY, nama TEXT NOT NULL,
            plat TEXT, odometerAwal REAL NOT NULL DEFAULT 0,
            createdAt INTEGER NOT NULL)''');
        await db.execute('''
          CREATE TABLE fuel_logs(
            id TEXT PRIMARY KEY, vehicleId TEXT NOT NULL
              REFERENCES vehicles(id) ON DELETE CASCADE,
            tanggal INTEGER NOT NULL, odometerKm REAL NOT NULL,
            liter REAL NOT NULL, hargaTotal INTEGER NOT NULL,
            isFullTank INTEGER NOT NULL DEFAULT 1, note TEXT)''');
        await db.execute(
            'CREATE INDEX idx_fuel_vt ON fuel_logs(vehicleId, tanggal, odometerKm)');
      },
    );
    return _db!;
  }
}
