import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // Pastikan sudah install geolocator
import '../services/api_service.dart';

class AduanScreen extends StatefulWidget {
  const AduanScreen({super.key});

  @override
  State<AduanScreen> createState() => _AduanScreenState();
}

class _AduanScreenState extends State<AduanScreen> {
  // Controller Input
  final TextEditingController _judulCtrl = TextEditingController();
  final TextEditingController _deskripsiCtrl = TextEditingController();
  String _prioritas = "sedang";

  // Lokasi
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getLocation(); // Cari lokasi saat buka
  }

  // Fungsi GPS
  Future<void> _getLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      try {
        Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
        if (mounted) setState(() => _currentPosition = position);
      } catch (e) {
        debugPrint("Gagal ambil lokasi: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151B25), // Background Dark
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER ---
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 15),
                  const Text(
                    "Form Aduan",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // --- FORM ---
              _buildLabel("Judul Kejadian"),
              TextField(
                controller: _judulCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Contoh: Tawuran"),
              ),

              _buildLabel("Prioritas Keamanan"),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C3542),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _prioritas,
                    dropdownColor: const Color(0xFF2C3542),
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white,
                    ),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    items: const [
                      DropdownMenuItem(
                        value: "sedang",
                        child: Text("Sedang (Normal)"),
                      ),
                      DropdownMenuItem(
                        value: "tinggi",
                        child: Text("Tinggi (Darurat)"),
                      ),
                    ],
                    onChanged: (val) {
                      setState(() => _prioritas = val!);
                    },
                  ),
                ),
              ),

              _buildLabel("Deskripsi Kejadian"),
              TextField(
                controller: _deskripsiCtrl,
                maxLines: 5,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Kronologi kejadian..."),
              ),

              const SizedBox(height: 40),

              // --- TOMBOL KIRIM ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // Validasi Sederhana
                    if (_judulCtrl.text.isEmpty ||
                        _deskripsiCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Mohon isi Judul dan Deskripsi!"),
                        ),
                      );
                    } else {
                      _showValidationDialog(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC107), // Kuning
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "KIRIM DATA",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Style
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 15.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[500]),
      filled: true,
      fillColor: const Color(0xFF2C3542),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  // --- DIALOG VALIDASI (SUDAH DIPERBAIKI) ---
  void _showValidationDialog(BuildContext parentContext) {
    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        // Gunakan nama dialogContext
        return Dialog(
          backgroundColor: Colors.white.withValues(alpha: 0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Kirimkan Data Aduan?",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    // TOMBOL TIDAK
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () =>
                            Navigator.pop(dialogContext), // Tutup dialog
                        child: const Text(
                          "TIDAK",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),

                    // TOMBOL YA
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        onPressed: () async {
                          // 1. Tutup Dialog Segera
                          Navigator.pop(dialogContext);

                          // 2. Tampilkan Loading (Gunakan parentContext/context)
                          // Cek mounted sebelum pakai context
                          if (mounted) {
                            ScaffoldMessenger.of(parentContext).showSnackBar(
                              const SnackBar(
                                content: Text("Sedang mengirim data..."),
                              ),
                            );
                          }

                          final api = ApiService();

                          // 3. Proses API
                          bool success = await api.sendReport(
                            judul: _judulCtrl.text,
                            deskripsi: _deskripsiCtrl.text,
                            tipe: 'aduan',
                            prioritas: _prioritas,
                            lat: _currentPosition?.latitude ?? -7.8,
                            lng: _currentPosition?.longitude ?? 112.5,
                          );

                          // 4. Cek Mounted LAGI setelah await
                          if (!mounted) return;

                          // 5. Navigasi Hasil
                          if (success) {
                            ScaffoldMessenger.of(parentContext).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.green,
                                content: Text("Sukses Terkirim!"),
                              ),
                            );
                            // Kembali ke Home
                            Navigator.pop(parentContext);
                          } else {
                            ScaffoldMessenger.of(parentContext).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.red,
                                content: Text("Gagal Kirim. Cek Koneksi"),
                              ),
                            );
                          }
                        },
                        child: const Text(
                          "YA",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
