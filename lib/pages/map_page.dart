import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // Import library peta
import 'package:latlong2/latlong.dart'; // Import koordinat (LatLng)

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151B25),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Interatif Maps",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      fontFamily: 'Serif',
                    ),
                  ),
                  Stack(
                    children: [
                      const Icon(
                        Icons.notifications,
                        color: Colors.grey,
                        size: 30,
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
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
                ],
              ),
            ),

            // --- MAP INTERAKTIF (LEAFLET) ---
            Expanded(
              flex: 3,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                // ClipRRect agar sudut peta melengkung
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: FlutterMap(
                    options: const MapOptions(
                      // PERBAIKAN: Gunakan LatLng
                      initialCenter: LatLng(-8.07, 111.9),
                      initialZoom: 14.0,
                    ),
                    children: [
                      // 1. Layer Peta (Tile)
                      TileLayer(
                        // Menggunakan Tema Gelap (CartoDB Dark Matter)
                        urlTemplate:
                            'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
                        subdomains: const ['a', 'b', 'c', 'd'],
                        userAgentPackageName: 'com.example.patrol_app',
                      ),

                      // 2. Layer Marker (Petugas)
                      MarkerLayer(
                        markers: [
                          // Marker 1: Briptu Budi
                          _buildCustomMarker(
                            point: const LatLng(
                              -8.07,
                              111.9,
                            ), // PERBAIKAN: Gunakan LatLng
                            name: "Briptu Budi",
                            imgUrl: 'https://via.placeholder.com/50',
                            color: Colors.blue,
                          ),
                          // Marker 2: Brigadir Joko
                          _buildCustomMarker(
                            point: const LatLng(
                              -8.065,
                              111.91,
                            ), // PERBAIKAN: Gunakan LatLng
                            name: "Brigadir Joko",
                            imgUrl: 'https://via.placeholder.com/50',
                            color: Colors.orange,
                          ),
                          // Marker 3: Bripka Andi
                          _buildCustomMarker(
                            point: const LatLng(
                              -8.075,
                              111.89,
                            ), // PERBAIKAN: Gunakan LatLng
                            name: "Bripka Andi",
                            imgUrl: 'https://via.placeholder.com/50',
                            color: Colors.red,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // --- LIST PETUGAS ---
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Petugas Patroli",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView(
                        children: [
                          _buildOfficerCard(
                            "Bripka Andi",
                            "Status: Berpatroli",
                            'https://via.placeholder.com/50',
                            Colors.red,
                          ),
                          _buildOfficerCard(
                            "Briptu Budi Santoso",
                            "Status: Siaga",
                            'https://via.placeholder.com/50',
                            Colors.blue,
                          ),
                          _buildOfficerCard(
                            "Brigadir Joko Susilo",
                            "Status: Siaga",
                            'https://via.placeholder.com/50',
                            Colors.orange,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi membuat Marker Peta Custom
  Marker _buildCustomMarker({
    required LatLng point, // PERBAIKAN: Ubah tipe data jadi LatLng
    required String name,
    required String imgUrl,
    required Color color,
  }) {
    return Marker(
      point: point,
      width: 80,
      height: 80,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: CircleAvatar(
              backgroundImage: NetworkImage(imgUrl),
              radius: 18,
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi membuat Card List Petugas
  Widget _buildOfficerCard(
    String name,
    String status,
    String imgUrl,
    Color statusColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF2C3542).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: statusColor, width: 2),
            ),
            child: CircleAvatar(
              backgroundImage: NetworkImage(imgUrl),
              radius: 25,
            ),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                status,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
