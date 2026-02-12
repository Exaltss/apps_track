import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151B25),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // 1. HEADER PROFIL (FOTO + NAMA)
              _buildProfileHeader(),

              const SizedBox(height: 30),

              // 2. STATISTIK SINGKAT (Opsional, agar terlihat keren)
              Row(
                children: [
                  _buildStatCard("Total Patroli", "128", Colors.blue),
                  const SizedBox(width: 15),
                  _buildStatCard("Laporan", "42", Colors.orange),
                ],
              ),

              const SizedBox(height: 30),

              // 3. MENU PENGATURAN
              _buildSectionTitle("Informasi Akun"),
              _buildMenuTile(
                icon: Icons.person_outline,
                title: "Data Diri",
                onTap: () {},
              ),
              _buildMenuTile(
                icon: Icons.badge_outlined,
                title: "Satuan Kerja",
                onTap: () {},
              ),

              const SizedBox(height: 20),

              _buildSectionTitle("Keamanan"),
              _buildMenuTile(
                icon: Icons.lock_outline,
                title: "Ubah Kata Sandi",
                onTap: () {},
              ),
              _buildMenuTile(
                icon: Icons.fingerprint,
                title: "Biometrik",
                isSwitch: true,
              ),

              const SizedBox(height: 20),

              _buildSectionTitle("Lainnya"),
              _buildMenuTile(
                icon: Icons.help_outline,
                title: "Bantuan & Dukungan",
                onTap: () {},
              ),
              _buildMenuTile(
                icon: Icons.info_outline,
                title: "Tentang Aplikasi",
                onTap: () {},
              ),

              const SizedBox(height: 40),

              // 4. TOMBOL LOGOUT
              _buildLogoutButton(context),

              const SizedBox(height: 20),
              Text(
                "Versi Aplikasi 1.0.0",
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          children: [
            // Foto Profil
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFFFC107),
                  width: 3,
                ), // Border Emas
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFC107).withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(
                  'https://via.placeholder.com/150',
                ), // Ganti dengan aset foto
              ),
            ),
            // Tombol Edit Foto
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          "Briptu Wisnu Wijaya",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Serif',
          ),
        ),
        const SizedBox(height: 5),
        Text(
          "NRP: 987654321",
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 16,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.green),
          ),
          child: const Text(
            "Status: Aktif",
            style: TextStyle(
              color: Colors.green,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFF2C3542),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 5),
        child: Text(
          title,
          style: const TextStyle(
            color: Color(0xFFFFC107), // Warna Emas
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    bool isSwitch = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF2C3542),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: isSwitch ? null : onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: isSwitch
            ? Switch(
                value: true,
                onChanged: (val) {},
                activeColor: const Color(0xFFFFC107),
              )
            : const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Tambahkan logika logout di sini
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Keluar dari aplikasi...")),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.withValues(
            alpha: 0.1,
          ), // Transparan merah
          foregroundColor: Colors.red, // Teks merah
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.red),
          ),
          elevation: 0,
        ),
        child: const Text(
          "Keluar Akun",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
