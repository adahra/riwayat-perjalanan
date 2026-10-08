import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/app_providers.dart';
import 'fuel_form.dart';
import 'garage.dart';
import 'history.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicles = ref.watch(vehicleListProvider);
    final selId = ref.watch(selectedVehicleIdProvider);
    final fmtRp = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Perjalanan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.garage),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const GarageScreen())),
          ),
        ],
      ),
      body: vehicles.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (v) {
          if (v.isEmpty) {
            return Center(
              child: FilledButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Tambah kendaraan'),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const GarageScreen())),
              ),
            );
          }
          final id = selId ?? v.first.id;
          final stats = ref.watch(statsProvider(id));
          final logs = ref.watch(fuelListProvider(id)).valueOrNull ?? [];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DropdownButtonFormField<String>(
                initialValue: id,
                items: v
                    .map((e) => DropdownMenuItem(
                        value: e.id, child: Text(e.nama)))
                    .toList(),
                onChanged: (x) => ref
                    .read(selectedVehicleIdProvider.notifier)
                    .state = x,
                decoration:
                    const InputDecoration(labelText: 'Kendaraan'),
              ),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: [
                _stat(context, 'Terakhir',
                    stats.konsumsiTerakhir == null ? '-' : '${stats.konsumsiTerakhir!.toStringAsFixed(1)} km/L'),
                _stat(context, 'Rata-rata',
                    stats.konsumsiRataRata == null ? '-' : '${stats.konsumsiRataRata!.toStringAsFixed(1)} km/L'),
                _stat(context, 'Biaya/km',
                    stats.biayaPerKm == null ? '-' : fmtRp.format(stats.biayaPerKm)),
                _stat(context, 'Bulan ini',
                    '${stats.kmBulanIni.toStringAsFixed(0)} km'),
              ]),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Terakhir (${logs.length})',
                      style: Theme.of(context).textTheme.titleMedium),
                  TextButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                HistoryScreen(vehicleId: id))),
                    child: const Text('Lihat semua'),
                  ),
                ],
              ),
              ...logs.take(5).map((e) => ListTile(
                    leading: const Icon(Icons.local_gas_station),
                    title: Text('${e.odometerKm} km • ${e.liter} L'),
                    subtitle: Text(fmtRp.format(e.hargaTotal)),
                  )),
              const SizedBox(height: 80),
            ],
          );
        },
      ),
      floatingActionButton: vehicles.valueOrNull?.isNotEmpty == true
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: const Text('Isi BBM'),
              onPressed: () {
                final v = vehicles.valueOrNull ?? [];
                final id = selId ?? (v.isNotEmpty ? v.first.id : null);
                if (id == null) return;
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            FuelFormScreen(vehicleId: id)));
              },
            )
          : null,
    );
  }

  Widget _stat(BuildContext c, String label, String value) {
    return SizedBox(
      width: 160,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(c).textTheme.labelMedium),
              const SizedBox(height: 4),
              Text(value, style: Theme.of(c).textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}
