import '../models/fuel_log.dart';

/// Statistik konsumsi metode full-to-full.
class FuelStats {
  final double? konsumsiTerakhir; // km/L
  final double? konsumsiRataRata;
  final double? biayaPerKm; // Rp/km
  final double totalKm;
  final double totalLiter;
  final int totalBiaya;
  final double kmBulanIni;
  final int count;

  const FuelStats({
    this.konsumsiTerakhir,
    this.konsumsiRataRata,
    this.biayaPerKm,
    this.totalKm = 0,
    this.totalLiter = 0,
    this.totalBiaya = 0,
    this.kmBulanIni = 0,
    this.count = 0,
  });

  static FuelStats compute(List<FuelLog> logsAsc) {
    if (logsAsc.isEmpty) return const FuelStats();
    final full = logsAsc.where((e) => e.isFullTank).toList();
    double tKm = 0, tL = 0;
    int tRp = 0;
    double? last;
    // segmen antar full-tank berurutan
    for (var i = 1; i < full.length; i++) {
      final dKm = full[i].odometerKm - full[i - 1].odometerKm;
      if (dKm > 0 && full[i].liter > 0) {
        tKm += dKm;
        tL += full[i].liter;
        tRp += full[i].hargaTotal;
        last = dKm / full[i].liter;
      }
    }
    // fallback: jika <2 full-tank, pakai semua entri berurutan
    if (full.length < 2 && logsAsc.length >= 2) {
      tKm = 0; tL = 0; tRp = 0; last = null;
      for (var i = 1; i < logsAsc.length; i++) {
        final dKm = logsAsc[i].odometerKm - logsAsc[i - 1].odometerKm;
        if (dKm > 0 && logsAsc[i].liter > 0) {
          tKm += dKm; tL += logsAsc[i].liter; tRp += logsAsc[i].hargaTotal;
          last = dKm / logsAsc[i].liter;
        }
      }
    }
    final now = DateTime.now();
    double bulan = 0;
    final asc = List<FuelLog>.from(logsAsc);
    for (var i = 1; i < asc.length; i++) {
      if (asc[i].tanggal.year == now.year &&
          asc[i].tanggal.month == now.month) {
        final d = asc[i].odometerKm - asc[i - 1].odometerKm;
        if (d > 0) bulan += d;
      }
    }
    return FuelStats(
      konsumsiTerakhir: last,
      konsumsiRataRata: tL > 0 ? tKm / tL : null,
      biayaPerKm: tKm > 0 ? tRp / tKm : null,
      totalKm: tKm,
      totalLiter: tL,
      totalBiaya: tRp,
      kmBulanIni: bulan,
      count: logsAsc.length,
    );
  }
}
