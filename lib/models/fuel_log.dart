class FuelLog {
  final String id;
  final String vehicleId;
  final DateTime tanggal;
  final double odometerKm;
  final double liter;
  final int hargaTotal;
  final bool isFullTank;
  final String? note;

  const FuelLog({
    required this.id,
    required this.vehicleId,
    required this.tanggal,
    required this.odometerKm,
    required this.liter,
    required this.hargaTotal,
    this.isFullTank = true,
    this.note,
  });

  double get hargaPerLiter => liter > 0 ? hargaTotal / liter : 0;

  Map<String, Object?> toMap() => {
        'id': id,
        'vehicleId': vehicleId,
        'tanggal': tanggal.millisecondsSinceEpoch,
        'odometerKm': odometerKm,
        'liter': liter,
        'hargaTotal': hargaTotal,
        'isFullTank': isFullTank ? 1 : 0,
        'note': note,
      };

  factory FuelLog.fromMap(Map<String, Object?> m) => FuelLog(
        id: m['id'] as String,
        vehicleId: m['vehicleId'] as String,
        tanggal: DateTime.fromMillisecondsSinceEpoch(m['tanggal'] as int),
        odometerKm: (m['odometerKm'] as num).toDouble(),
        liter: (m['liter'] as num).toDouble(),
        hargaTotal: (m['hargaTotal'] as num).toInt(),
        isFullTank: (m['isFullTank'] as num).toInt() == 1,
        note: m['note'] as String?,
      );
}

class OdometerException implements Exception {
  final String message;
  OdometerException(this.message);
  @override
  String toString() => message;
}
