import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import '../services/api_service.dart';
import 'aduan_screen.dart';
import 'checkpoint_screen.dart';
import 'history_screen.dart';
import 'map_screen.dart';
import 'profile_screen.dart';

// --- SHELL UTAMA (NAVBAR) ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const BerandaTab(),
    const AduanScreen(),
    const HistoryScreen(),
    const MapScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151B25),
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF222B36),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: const Color(0xFF222B36),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFFFFC107),
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.campaign), label: 'Aduan'),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'Riwayat',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Peta'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}

// ==========================================================
// --- TAB BERANDA ---
// ==========================================================

enum PatrolStatus { idle, patrolling, standby, emergency }

class BerandaTab extends StatefulWidget {
  const BerandaTab({super.key});

  @override
  State<BerandaTab> createState() => _BerandaTabState();
}

class _BerandaTabState extends State<BerandaTab> {
  PatrolStatus _status = PatrolStatus.idle;
  String _fullname = "Memuat...";
  String _pangkat = "";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _fullname =
            prefs.getString('nama_lengkap') ??
            prefs.getString('username') ??
            "Petugas";
        _pangkat = prefs.getString('pangkat') ?? "Anggota";
      });
    }
  }

  void _handleMainButtonTap() {
    if (_status == PatrolStatus.idle) {
      _checkGpsAndStartPatrol();
    } else {
      _confirmStopPatrol();
    }
  }

  // 1. Cek GPS & Izin Lokasi
  Future<void> _checkGpsAndStartPatrol() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      _showGpsDialog();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Izin lokasi wajib diterima!")),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Izin lokasi ditolak permanen.")),
      );
      return;
    }

    if (!mounted) return;
    _showStartConfirmation();
  }

  // 2. Dialog Nyalakan GPS
  void _showGpsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("GPS Tidak Aktif"),
        content: const Text("Aktifkan GPS untuk memulai patroli."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openLocationSettings();
            },
            child: const Text("Buka Pengaturan"),
          ),
        ],
      ),
    );
  }

  // 3. Dialog Konfirmasi Mulai
  void _showStartConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Mulai Patroli?"),
        content: const Text("Status dan lokasi Anda akan mulai direkam."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D47A1),
            ),
            onPressed: () {
              Navigator.pop(context);
              _processStartPatrol();
            },
            child: const Text(
              "YA, MULAI",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // 4. Proses API Start Patroli
  Future<void> _processStartPatrol() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      bool success = await ApiService().updatePatrolStatus(
        lat: position.latitude,
        long: position.longitude,
        status: 'start',
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (success) {
        setState(() {
          _status = PatrolStatus.patrolling;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text("Patroli Dimulai!"),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text("Gagal terhubung ke server."),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Terjadi kesalahan.")));
      }
    }
  }

  // 5. Konfirmasi Berhenti
  void _confirmStopPatrol() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Selesai Patroli?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _status = PatrolStatus.idle;
              });
            },
            child: const Text("AKHIRI", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _activateStandbyMode() {
    setState(() {
      _status = PatrolStatus.standby;
    });
  }

  void _activateEmergencyMode() {
    setState(() {
      _status = PatrolStatus.emergency;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // HEADER
            Row(
              children: [
                const CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.yellow,
                  child: Icon(Icons.person, color: Colors.black),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "SELAMAT DATANG",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    Text(
                      "$_pangkat $_fullname",
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.notifications, color: Colors.grey, size: 30),
              ],
            ),
            const SizedBox(height: 20),

            // TRACKING BAR
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF2C3542),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: const [
                  Icon(Icons.location_on, color: Colors.blue),
                  SizedBox(width: 10),
                  Text(
                    "Realtime Tracking Coordinate",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // TOMBOL UTAMA
            _BouncingButton(
              onTap: _isLoading ? () {} : _handleMainButtonTap,
              child: _isLoading
                  ? Container(
                      width: double.infinity,
                      height: 140,
                      decoration: BoxDecoration(
                        color: const Color(0xFF151B25),
                        borderRadius: const BorderRadius.all(
                          Radius.elliptical(300, 180),
                        ),
                        border: Border.all(color: Colors.grey, width: 3),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    )
                  : _buildMainButton(),
            ),

            const SizedBox(height: 30),

            // MENU KECIL
            Row(
              children: [
                Expanded(
                  child: _BouncingButton(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CheckpointScreen(),
                      ),
                    ),
                    child: _buildMenuButton(
                      const Color(0xFF5DD35D),
                      Icons.visibility,
                      "Tandai rute\nCheckpoint",
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _BouncingButton(
                    onTap: _activateStandbyMode,
                    child: _buildMenuButton(
                      const Color(0xFFD48C56),
                      Icons.local_cafe,
                      "Sedang\nBersiaga",
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // TOMBOL DARURAT
            _BouncingButton(
              onTap: _activateEmergencyMode,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Kirimkan Sinyal Darurat",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // JADWAL
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2C3542),
                borderRadius: BorderRadius.circular(15),
              ),
              child: ExpansionTile(
                title: const Text(
                  "Jadwal Patroli",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                iconColor: Colors.white,
                collapsedIconColor: Colors.white,
                children: [
                  _buildScheduleCard(
                    "Kamis 28/01/2025",
                    "17.00 - 21.00",
                    "desa podorejo - desa kauman",
                    "terlaksana",
                    const Color(0xFF5DD35D),
                  ),
                  const SizedBox(height: 10),
                  _buildScheduleCard(
                    "Senin 07/02/2025",
                    "08.00 - 11.00",
                    "desa mangunsari - desa boyolangu",
                    "terjadwal",
                    Colors.red,
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- WIDGET PENDUKUNG ---
  Widget _buildMainButton() {
    Color borderColor = const Color(0xFFFFC107);
    Color textColor = const Color(0xFFFFC107);
    String textTop = "Mulai", textBottom = "Berpatroli";

    if (_status == PatrolStatus.patrolling) {
      borderColor = const Color(0xFF5DD35D);
      textColor = borderColor;
      textTop = "Hentikan";
      textBottom = "Patroli";
    } else if (_status == PatrolStatus.standby) {
      borderColor = const Color(0xFFD48C56);
      textColor = borderColor;
      textTop = "Lanjutkan";
      textBottom = "Patroli";
    } else if (_status == PatrolStatus.emergency) {
      borderColor = Colors.red;
      textColor = Colors.red;
      textTop = "Hentikan";
      textBottom = "Sinyal Darurat";
    }

    return Center(
      child: Container(
        width: double.infinity,
        height: 140,
        decoration: BoxDecoration(
          color: const Color(0xFF151B25),
          borderRadius: const BorderRadius.all(Radius.elliptical(300, 180)),
          border: Border.all(color: borderColor, width: 3),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              textTop,
              style: TextStyle(
                color: textColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                fontFamily: 'Serif',
              ),
            ),
            Text(
              textBottom,
              style: TextStyle(
                color: textColor,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                fontFamily: 'Serif',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(Color color, IconData icon, String label) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 30),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(
    String date,
    String time,
    String location,
    String status,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF222B36),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 10,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          date,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFC107),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            status,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "$time | $location",
                      style: TextStyle(color: Colors.grey[400], fontSize: 13),
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
}

class _BouncingButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _BouncingButton({required this.child, required this.onTap});
  @override
  State<_BouncingButton> createState() => _BouncingButtonState();
}

class _BouncingButtonState extends State<_BouncingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}
