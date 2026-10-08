import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/fuel_log.dart';
import '../models/vehicle.dart';
import '../repositories/fuel_repo.dart';
import '../repositories/vehicle_repo.dart';
import 'stats.dart';

const _uuid = Uuid();
String newId() => _uuid.v4();

final vehicleRepoProvider = Provider((_) => VehicleRepo());
final fuelRepoProvider = Provider((_) => FuelRepo());

final vehicleListProvider =
    AsyncNotifierProvider<VehicleList, List<Vehicle>>(VehicleList.new);

class VehicleList extends AsyncNotifier<List<Vehicle>> {
  @override
  Future<List<Vehicle>> build() =>
      ref.watch(vehicleRepoProvider).all();

  Future<void> add(String nama, String? plat, double odo) async {
    await ref.read(vehicleRepoProvider).upsert(Vehicle(
        id: newId(), nama: nama, plat: plat, odometerAwal: odo,
        createdAt: DateTime.now()));
    ref.invalidateSelf();
  }

  Future<void> remove(String id) async {
    await ref.read(vehicleRepoProvider).remove(id);
    ref.invalidateSelf();
  }
}

final selectedVehicleIdProvider = StateProvider<String?>((_) => null);

final fuelListProvider = AsyncNotifierProviderFamily<FuelList, List<FuelLog>, String>(
    FuelList.new);

class FuelList extends FamilyAsyncNotifier<List<FuelLog>, String> {
  @override
  Future<List<FuelLog>> build(String vehicleId) =>
      ref.watch(fuelRepoProvider).byVehicle(vehicleId);

  Future<void> add(FuelLog log) async {
    await ref.read(fuelRepoProvider).insert(log);
    ref.invalidateSelf();
  }

  Future<void> updateOne(FuelLog log) async {
    await ref.read(fuelRepoProvider).update(log);
    ref.invalidateSelf();
  }

  Future<void> removeOne(String id) async {
    await ref.read(fuelRepoProvider).remove(id);
    ref.invalidateSelf();
  }
}

final statsProvider = ProviderFamily<FuelStats, String>((ref, vehicleId) {
  final logs =
      ref.watch(fuelListProvider(vehicleId)).valueOrNull ?? [];
  final asc = List<FuelLog>.from(logs)
    ..sort((a, b) {
      final c = a.tanggal.compareTo(b.tanggal);
      return c != 0 ? c : a.odometerKm.compareTo(b.odometerKm);
    });
  return FuelStats.compute(asc);
});

final lastOdometerProvider =
    FutureProviderFamily<double?, String>((ref, vehicleId) {
  return ref.watch(fuelRepoProvider).lastOdometer(vehicleId);
});
