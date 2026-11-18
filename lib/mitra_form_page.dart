import 'package:flutter/material.dart';

class MitraFormPage extends StatefulWidget {
  const MitraFormPage({super.key});

  @override
  State<MitraFormPage> createState() => _MitraFormPageState();
}

class _MitraFormPageState extends State<MitraFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _beratController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();
  
  String _selectedJenisSampah = 'Organik Kulit Buah/Sayur';
  final List<String> _jenisSampahList = [
    'Organik Kulit Buah/Sayur',
    'Sisa Makanan Dapur',
    'Limbah Organik Pasar/Cafe'
  ];

  @override
  void dispose() {
    _beratController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Ajukan Penjemputan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Smart Pick-Up Scheduler',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF198754)),
              ),
              const SizedBox(height: 4),
              const Text(
                'Pilih jenis limbah organik, isi estimasi volume, dan jadwalkan penjemputan usahamu.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // Dropdown Jenis Limbah
              DropdownButtonFormField<String>(
                value: _selectedJenisSampah,
                decoration: InputDecoration(
                  labelText: 'Jenis Limbah Organik',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: _jenisSampahList.map((String jenis) {
                  return DropdownMenuItem(
                    value: jenis,
                    child: Text(jenis, style: const TextStyle(fontSize: 14)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedJenisSampah = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Input Estimasi Berat
              TextFormField(
                controller: _beratController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Estimasi Berat (kg)',
                  hintText: 'Contoh: 35',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Estimasi berat tidak boleh kosong!';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Masukkan angka yang valid!';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Catatan Kurir
              TextFormField(
                controller: _catatanController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Catatan untuk Kurir (Opsional)',
                  hintText: 'Contoh: Masuk lewat gang samping, tempat sampah di belakang dapur.',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              // Tombol Submit
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF198754),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    String beratInput = _beratController.text;
                    String catatanInput = _catatanController.text;

                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Berhasil Diajukan!'),
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Jenis: $_selectedJenisSampah'),
                              Text('Estimasi Berat: $beratInput kg'),
                              Text('Catatan: ${catatanInput.isEmpty ? '-' : catatanInput}'),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Tutup dialog
                                Navigator.pop(context); // Kembali ke dashboard
                              },
                              child: const Text('OK', style: TextStyle(color: Color(0xFF198754))),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: const Text('Kirim Pengajuan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}