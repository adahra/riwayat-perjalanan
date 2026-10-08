import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/fuel_log.dart';
import '../providers/app_providers.dart';

class FuelFormScreen extends ConsumerStatefulWidget {
  final String vehicleId;
  final FuelLog? existing;
  const FuelFormScreen({super.key, required this.vehicleId, this.existing});

  @override
  ConsumerState<FuelFormScreen> createState() => _FuelFormScreenState();
}

class _FuelFormScreenState extends ConsumerState<FuelFormScreen> {
  final _form = GlobalKey<FormState>();
  late DateTime _tgl;
  late TextEditingController _odo, _liter, _harga, _note;
  bool _full = true;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _tgl = e?.tanggal ?? DateTime.now();
    _odo = TextEditingController(text: e?.odometerKm.toString() ?? '');
    _liter = TextEditingController(text: e?.liter.toString() ?? '');
    _harga = TextEditingController(text: e?.hargaTotal.toString() ?? '');
    _note = TextEditingController(text: e?.note ?? '');
    _full = e?.isFullTank ?? true;
  }

  @override
  void dispose() {
    _odo.dispose(); _liter.dispose(); _harga.dispose(); _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final log = FuelLog(
      id: widget.existing?.id ?? newId(),
      vehicleId: widget.vehicleId,
      tanggal: _tgl,
      odometerKm: double.parse(_odo.text.replaceAll(',', '.')),
      liter: double.parse(_liter.text.replaceAll(',', '.')),
      hargaTotal: int.parse(_harga.text),
      isFullTank: _full,
      note: _note.text.isEmpty ? null : _note.text,
    );
    try {
      final n = ref.read(fuelListProvider(widget.vehicleId).notifier);
      if (widget.existing == null) {
        await n.add(log);
      } else {
        await n.updateOne(log);
      }
      if (mounted) Navigator.pop(context);
    } on OdometerException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lastOdo =
        ref.watch(lastOdometerProvider(widget.vehicleId)).valueOrNull;
    final fmt = DateFormat('dd MMM yyyy', 'id_ID');
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.existing == null ? 'Isi BBM' : 'Edit BBM')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (lastOdo != null && widget.existing == null)
              Card(
                  child: ListTile(
                      leading: const Icon(Icons.speed),
                      title: Text('Odometer terakhir: $lastOdo km'))),
            ListTile(
              title: Text('Tanggal: ${fmt.format(_tgl)}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final d = await showDatePicker(
                    context: context,
                    initialDate: _tgl,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now());
                if (d != null) setState(() => _tgl = d);
              },
            ),
            TextFormField(
              controller: _odo,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration:
                  const InputDecoration(labelText: 'Odometer (km)'),
              validator: (v) =>
                  (double.tryParse((v ?? '').replaceAll(',', '.')) ?? -1) < 0
                      ? 'Masukkan angka KM'
                      : null,
            ),
            TextFormField(
              controller: _liter,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Liter'),
              validator: (v) =>
                  (double.tryParse((v ?? '').replaceAll(',', '.')) ?? 0) <= 0
                      ? 'Liter harus > 0'
                      : null,
            ),
            TextFormField(
              controller: _harga,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: 'Total harga (Rp)'),
              validator: (v) =>
                  (int.tryParse(v ?? '') ?? -1) < 0 ? 'Harga invalid' : null,
            ),
            CheckboxListTile(
              title: const Text('Tangki penuh (full tank)'),
              value: _full,
              onChanged: (v) => setState(() => _full = v ?? true),
            ),
            TextFormField(
                controller: _note,
                decoration:
                    const InputDecoration(labelText: 'Catatan (opsional)')),
            const SizedBox(height: 16),
            FilledButton(onPressed: _save, child: const Text('Simpan')),
          ],
        ),
      ),
    );
  }
}
