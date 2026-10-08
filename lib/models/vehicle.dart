class Vehicle {
  final String id;
  final String nama;
  final String? plat;
  final double odometerAwal;
  final DateTime createdAt;

  const Vehicle({
    required this.id,
    required this.nama,
    this.plat,
    this.odometerAwal = 0,
    required this.createdAt,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'nama': nama,
        'plat': plat,
        'odometerAwal': odometerAwal,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory Vehicle.fromMap(Map<String, Object?> m) => Vehicle(
        id: m['id'] as String,
        nama: m['nama'] as String,
        plat: m['plat'] as String?,
        odometerAwal: (m['odometerAwal'] as num).toDouble(),
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(m['createdAt'] as int),
      );
}
