import 'package:sqflite/sqflite.dart';
import '../core/database/app_db.dart';
import '../models/vehicle.dart';

class VehicleRepo {
  Future<List<Vehicle>> all() async {
    final db = await AppDb.instance.db;
    final rows = await db.query('vehicles', orderBy: 'createdAt ASC');
    return rows.map(Vehicle.fromMap).toList();
  }

  Future<void> upsert(Vehicle v) async {
    final db = await AppDb.instance.db;
    await db.insert('vehicles', v.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> remove(String id) async {
    final db = await AppDb.instance.db;
    await db.delete('vehicles', where: 'id = ?', whereArgs: [id]);
  }
}
