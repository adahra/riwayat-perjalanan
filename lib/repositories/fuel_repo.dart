import '../core/database/app_db.dart';
import '../models/fuel_log.dart';

class FuelRepo {
  Future<List<FuelLog>> byVehicle(String vehicleId) async {
    final db = await AppDb.instance.db;
    final rows = await db.query('fuel_logs',
        where: 'vehicleId = ?',
        whereArgs: [vehicleId],
        orderBy: 'tanggal DESC, odometerKm DESC');
    return rows.map(FuelLog.fromMap).toList();
  }

  Future<double?> lastOdometer(String vehicleId) async {
    final db = await AppDb.instance.db;
    final rows = await db.query('fuel_logs',
        columns: ['MAX(odometerKm) AS m'],
        where: 'vehicleId = ?',
        whereArgs: [vehicleId]);
    final m = rows.first['m'];
    return m == null ? null : (m as num).toDouble();
  }

  Future<void> insert(FuelLog log) async {
    _validate(log);
    final db = await AppDb.instance.db;
    final last = await lastOdometer(log.vehicleId);
    if (last != null && log.odometerKm <= last) {
      throw OdometerException(
          'Odometer (${log.odometerKm}) harus > terakhir ($last)');
    }
    await db.insert('fuel_logs', log.toMap());
  }

  Future<void> update(FuelLog log) async {
    _validate(log);
    final db = await AppDb.instance.db;
    await db.update('fuel_logs', log.toMap(),
        where: 'id = ?', whereArgs: [log.id]);
  }

  Future<void> remove(String id) async {
    final db = await AppDb.instance.db;
    await db.delete('fuel_logs', where: 'id = ?', whereArgs: [id]);
  }

  void _validate(FuelLog l) {
    if (l.liter <= 0) throw OdometerException('Liter harus > 0');
    if (l.hargaTotal < 0) throw OdometerException('Harga tidak valid');
    if (l.odometerKm < 0) throw OdometerException('Odometer tidak valid');
    if (l.tanggal.isAfter(DateTime.now().add(const Duration(days: 1)))) {
      throw OdometerException('Tanggal tidak boleh masa depan');
    }
  }
}
