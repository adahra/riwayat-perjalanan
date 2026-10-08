import 'package:flutter_test/flutter_test.dart';
import 'package:riwayat_perjalanan/models/fuel_log.dart';
import 'package:riwayat_perjalanan/providers/stats.dart';

FuelLog _l(String id, double odo, double liter, int rp) => FuelLog(
    id: id, vehicleId: 'v1', tanggal: DateTime(2026, 1, int.parse(id)),
    odometerKm: odo, liter: liter, hargaTotal: rp, isFullTank: true);

void main() {
  test('konsumsi full-to-full benar', () {
    final logs = [_l('1', 1000, 10, 100000), _l('2', 1500, 10, 100000)];
    final s = FuelStats.compute(logs);
    expect(s.konsumsiRataRata, 50.0);
    expect(s.konsumsiTerakhir, 50.0);
  });

  test('kosong -> null stats', () {
    final s = FuelStats.compute([]);
    expect(s.konsumsiRataRata, isNull);
    expect(s.count, 0);
  });
}
