import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';

class GarageScreen extends ConsumerStatefulWidget {
  const GarageScreen({super.key});
  @override
  ConsumerState<GarageScreen> createState() => _GarageScreenState();
}

class _GarageScreenState extends ConsumerState<GarageScreen> {
  Future<void> _dialog() async {
    final nama = TextEditingController();
    final plat = TextEditingController();
    final odo = TextEditingController(text: '0');
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Tambah kendaraan'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nama,
              decoration: const InputDecoration(labelText: 'Nama (mis. Vario)')),
          TextField(controller: plat,
              decoration: const InputDecoration(labelText: 'Plat (opsional)')),
          TextField(controller: odo,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: 'Odometer awal (km)')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false),
              child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(c, true),
              child: const Text('Simpan')),
        ],
      ),
    );
    if (ok == true && nama.text.isNotEmpty) {
      await ref.read(vehicleListProvider.notifier).add(
          nama.text, plat.text.isEmpty ? null : plat.text,
          double.tryParse(odo.text) ?? 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(vehicleListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Garasi')),
      body: list.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (v) => v.isEmpty
            ? const Center(child: Text('Belum ada kendaraan. Tambahkan dulu.'))
            : ListView.builder(
                itemCount: v.length,
                itemBuilder: (c, i) => ListTile(
                  leading: const Icon(Icons.directions_car),
                  title: Text(v[i].nama),
                  subtitle: Text(
                      '${v[i].plat ?? '-'} • awal ${v[i].odometerAwal} km'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => ref
                        .read(vehicleListProvider.notifier)
                        .remove(v[i].id),
                  ),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: _dialog, child: const Icon(Icons.add)),
    );
  }
}
