import 'package:flutter/material.dart';
import 'checkpoint_page.dart';

// Enum untuk status aplikasi
enum PatrolStatus { idle, patrolling, standby, emergency }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Status awal
  PatrolStatus _status = PatrolStatus.idle;

  // --- LOGIKA TOMBOL ---

  // 1. Logika Tombol Utama
  void _handleMainButtonTap() {
    setState(() {
      if (_status == PatrolStatus.idle) {
        _status = PatrolStatus.patrolling;
      } else if (_status == PatrolStatus.patrolling) {
        _status = PatrolStatus.idle;
      } else if (_status == PatrolStatus.standby) {
        _status = PatrolStatus.patrolling;
      } else if (_status == PatrolStatus.emergency) {
        _status = PatrolStatus.idle;
      }
    });
  }

  // 2. Logika Tombol Siaga
  void _activateStandbyMode() {
    setState(() {
      _status = PatrolStatus.standby;
    });
  }

  // 3. Logika Tombol Darurat
  void _activateEmergencyMode() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white.withValues(alpha: 0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Apakah anda ingin mengirimkan sinyal darurat?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Serif',
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "TIDAK",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _status = PatrolStatus.emergency;
                        });
                      },
                      child: const Text(
                        "YA",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildTrackingBar(),
            const SizedBox(height: 30),

            // 1. TOMBOL UTAMA (BOUNCING)
            _BouncingButton(
              onTap: _handleMainButtonTap,
              child: _buildMainButton(),
            ),

            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  // 2. TOMBOL CHECKPOINT (BOUNCING)
                  child: _BouncingButton(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CheckpointPage(),
                        ),
                      );
                    },
                    child: const _MenuButton(
                      color: Color(0xFF5DD35D),
                      icon: Icons.visibility,
                      label: "Tandai rute\nCheckpoint",
                      textColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  // 3. TOMBOL SIAGA (BOUNCING)
                  child: _BouncingButton(
                    onTap: _activateStandbyMode,
                    child: const _MenuButton(
                      color: Color(0xFFD48C56),
                      icon: Icons.local_cafe,
                      label: "Sedang\nBersiaga",
                      textColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // 4. TOMBOL DARURAT (BOUNCING)
            _BouncingButton(
              onTap: _activateEmergencyMode,
              child: _buildEmergencyTriggerButton(),
            ),

            const SizedBox(height: 25),

            // 5. DROPDOWN JADWAL PATROLI (BARU)
            Container(
              decoration: BoxDecoration(
                color: const Color(
                  0xFF2C3542,
                ), // Warna background header dropdown
                borderRadius: BorderRadius.circular(15),
              ),
              child: Theme(
                // Menghilangkan garis divider bawaan Flutter
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: const Text(
                    "Jadwal Patroli",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Serif',
                    ),
                  ),
                  iconColor: Colors.white, // Warna panah saat terbuka
                  collapsedIconColor: Colors.white, // Warna panah saat tertutup
                  childrenPadding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                  children: [
                    const SizedBox(height: 10),
                    // Item Jadwal 1
                    _buildScheduleCard(
                      date: "Kamis 28/01/2025",
                      time: "17.00 - 21.00",
                      location: "desa podorejo - desa kauman",
                      status: "terlaksana",
                      color: const Color(0xFF5DD35D),
                    ),
                    const SizedBox(height: 15),
                    // Item Jadwal 2
                    _buildScheduleCard(
                      date: "Senin 07/02/2025",
                      time: "08.00 - 11.00",
                      location: "desa mangunsari - desa boyolangu",
                      status: "terjadwal",
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            ),

            // Tambahan ruang di bawah agar scroll enak
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildMainButton() {
    Color borderColor;
    Color textColor;
    String textTop;
    String textBottom;
    List<BoxShadow> shadows = [];

    switch (_status) {
      case PatrolStatus.patrolling:
        borderColor = const Color(0xFF5DD35D);
        textColor = const Color(0xFF5DD35D);
        textTop = "Hentikan";
        textBottom = "Patroli";
        break;

      case PatrolStatus.standby:
        borderColor = const Color(0xFFD48C56);
        textColor = const Color(0xFFD48C56);
        textTop = "Lanjutkan";
        textBottom = "Patroli";
        break;

      case PatrolStatus.emergency:
        borderColor = Colors.red;
        textColor = Colors.red;
        textTop = "Hentikan";
        textBottom = "Sinyal Darurat";
        shadows = [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.6),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ];
        break;

      case PatrolStatus.idle:
        borderColor = const Color(0xFFFFC107);
        textColor = const Color(0xFFFFC107);
        textTop = "Mulai";
        textBottom = "Berpatroli";
        break;
    }

    return Center(
      child: Container(
        width: double.infinity,
        height: 140,
        decoration: BoxDecoration(
          color: const Color(0xFF151B25),
          borderRadius: const BorderRadius.all(Radius.elliptical(300, 180)),
          border: Border.all(color: borderColor, width: 3),
          boxShadow: shadows,
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

  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: Colors.yellow,
          backgroundImage: const NetworkImage('https://via.placeholder.com/50'),
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
              "Briptu Wisnu Wijaya",
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
          ],
        ),
        const Spacer(),
        Stack(
          children: [
            const Icon(Icons.notifications, color: Colors.grey, size: 30),
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
                  '1',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTrackingBar() {
    return Container(
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
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyTriggerButton() {
    return Container(
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
          Icon(Icons.warning_amber_rounded, color: Colors.white, size: 32),
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
    );
  }

  Widget _buildScheduleCard({
    required String date,
    required String time,
    required String location,
    required String status,
    required Color color,
  }) {
    // Saya sedikit menggelapkan warna card agar kontras dengan background dropdown
    return Container(
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

class _MenuButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final Color textColor;

  const _MenuButton({
    required this.color,
    required this.icon,
    required this.label,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 30),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// WIDGET KHUSUS: Bouncing Button (Efek Tekan)
// ==========================================
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
      duration: const Duration(milliseconds: 100), // Kecepatan animasi
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
