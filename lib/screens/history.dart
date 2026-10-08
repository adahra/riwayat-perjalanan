import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/app_providers.dart';
import 'fuel_form.dart';

class HistoryScreen extends ConsumerWidget {
  final String vehicleId;
  const HistoryScreen({super.key, required this.vehicleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(fuelListProvider(vehicleId));
    final fmtD = DateFormat('dd MMM yyyy', 'id_ID');
    final fmtRp = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat')),
      body: logs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (l) => l.isEmpty
            ? const Center(child: Text('Belum ada catatan BBM.'))
            : ListView.builder(
                itemCount: l.length,
                itemBuilder: (c, i) {
                  final e = l[i];
                  return Dismissible(
                    key: ValueKey(e.id),
                    background: Container(color: Colors.red),
                    onDismissed: (_) async {
                      await ref
                          .read(fuelListProvider(vehicleId).notifier)
                          .removeOne(e.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Dihapus'),
                            action: SnackBarAction(
                              label: 'Urungkan',
                              onPressed: () => ref
                                  .read(fuelListProvider(vehicleId).notifier)
                                  .add(e),
                            ),
                          ),
                        );
                      }
                    },
                    child: ListTile(
                      leading: Icon(e.isFullTank
                          ? Icons.local_gas_station
                          : Icons.opacity),
                      title: Text(
                          '${fmtD.format(e.tanggal)} • ${e.odometerKm} km'),
                      subtitle: Text(
                          '${e.liter} L • ${fmtRp.format(e.hargaTotal)}${e.note != null ? ' • ${e.note}' : ''}'),
                      trailing: Text(
                          '${e.hargaPerLiter.toStringAsFixed(0)}/L',
                          style: Theme.of(context).textTheme.labelSmall),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => FuelFormScreen(
                                  vehicleId: vehicleId, existing: e))),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
