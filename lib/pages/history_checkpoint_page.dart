import 'package:flutter/material.dart';

class HistoryCheckpointPage extends StatelessWidget {
  const HistoryCheckpointPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151B25),
      appBar: AppBar(
        backgroundColor: const Color(0xFF151B25),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.notifications, color: Colors.grey, size: 30),
                Positioned(
                  right: 0,
                  top: 10,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      '14',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Riwayat\nCheckpoint",
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                fontFamily: 'Serif',
                height: 1.0, // Rapatkan jarak antar baris
              ),
            ),
            const SizedBox(height: 30),

            // List Item 1
            _buildHistoryCard(
              title: "Pengedaran Narkoba",
              subtitle: "Ditemukan Lokasi Pengedar Narkoba di Daerah...",
              status: "Status: Menunggu",
              statusColor: const Color(0xFFC8A036), // Gold/Kuning tua
              level: "Tingkat: Tinggi",
              levelColor: Colors.red,
            ),

            const SizedBox(height: 15),

            // List Item 2
            _buildHistoryCard(
              title: "Tongkrongan Judi Online",
              subtitle: "Ditemukan Tempat Perkumpulan Pemain Judol...",
              status: "Status: Selesai",
              statusColor: const Color(0xFF4CAF50), // Hijau
              level: "Tingkat: Sedang",
              levelColor: const Color(0xFFC8A036), // Gold/Kuning tua
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard({
    required String title,
    required String subtitle,
    required String status,
    required Color statusColor,
    required String level,
    required Color levelColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2C3542),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon
          Container(
            height: 50,
            width: 40,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFC8A036)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.location_on_outlined,
              color: Color(0xFFC8A036),
            ),
          ),
          const SizedBox(width: 12),

          // Middle Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Right Chips
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildChip(status, statusColor),
              const SizedBox(height: 5),
              _buildChip(level, levelColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
