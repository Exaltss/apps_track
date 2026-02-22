import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // IP Emulator Android (JANGAN GANTI JIKA PAKAI EMULATOR)
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // --- 1. LOGIN ---
  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        body: {'username': username, 'password': password},
        headers: {'Accept': 'application/json'},
      );

      debugPrint("Login Response: ${response.body}"); // DEBUG

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['access_token']);

        if (data['user'] != null) {
          await prefs.setInt('user_id', data['user']['id']);
          await prefs.setString('username', data['user']['username']);

          if (data['user']['personnel'] != null) {
            await prefs.setString(
              'nama_lengkap',
              data['user']['personnel']['full_name'] ??
                  data['user']['username'],
            );
            await prefs.setString(
              'pangkat',
              data['user']['personnel']['rank'] ?? 'Petugas',
            );
          } else {
            // Default jika data personel kosong
            await prefs.setString('nama_lengkap', data['user']['username']);
            await prefs.setString('pangkat', 'Petugas');
          }
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Error Login: $e");
      return false;
    }
  }

  // --- 2. UPDATE STATUS PATROLI (Debug Version) ---
  Future<bool> updatePatrolStatus({
    required double lat,
    required double long,
    required String status,
  }) async {
    try {
      final token = await getToken();

      if (token == null) {
        debugPrint("ERROR: Token tidak ditemukan. User harus login ulang.");
        return false;
      }

      debugPrint(
        "Mengirim Data ke Server... Lat: $lat, Long: $long, Status: $status",
      );

      final response = await http.post(
        Uri.parse('$baseUrl/tracking'),
        headers: {
          'Authorization': 'Bearer $token', // Spasi wajib ada
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'latitude': lat,
          'longitude': long,
          'status': status,
        }),
      );

      debugPrint("--- HASIL DARI SERVER ---");
      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Body: ${response.body}");
      debugPrint("-------------------------");

      // Berhasil jika 200 OK
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("Error Koneksi/Exception: $e");
      return false;
    }
  }

  // --- 3. KIRIM ADUAN ---
  Future<bool> sendReport({
    required String judul,
    required String deskripsi,
    required String tipe,
    required String prioritas,
    required double lat,
    required double lng,
  }) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/reports'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'title': judul,
          'description': deskripsi,
          'type': tipe,
          'priority': prioritas,
          'latitude': lat,
          'longitude': lng,
        }),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // --- Fungsi Lain (Logout/History/Profil/Checkpoint) biarkan seperti sebelumnya ---
  // (Pastikan fungsi kirimCheckpoint ada jika dipanggil di halaman lain)
  Future<bool> kirimCheckpoint(double lat, double long) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/tracking'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'latitude': lat, 'longitude': long}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // --- 6. HISTORY ---
  Future<List<dynamic>> getHistoryLaporan() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/reports'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // --- 7. PROFIL ---
  Future<Map<String, dynamic>> getProfile() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/user'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Gagal load profil');
  }

  Future<void> logout() async {
    // ... kode lama ...
  }
}
