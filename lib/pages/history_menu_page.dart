import 'package:flutter/material.dart';
import 'history_checkpoint_page.dart';
import 'history_aduan_page.dart';

class HistoryMenuPage extends StatelessWidget {
  const HistoryMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151B25),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER (JUDUL + NOTIFIKASI) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Riwayat",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
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

              const SizedBox(height: 40),

              // Tombol Riwayat Checkpoint (Dengan Efek Bouncing)
              _BouncingButton(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HistoryCheckpointPage(),
                    ),
                  );
                },
                child: _buildBigButtonContent(
                  text: "Riwayat Checkpoint",
                  color: const Color(0xFF4CAF50),
                ),
              ),

              const SizedBox(height: 20),

              // Tombol Riwayat Aduan (Dengan Efek Bouncing)
              _BouncingButton(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HistoryAduanPage(),
                    ),
                  );
                },
                child: _buildBigButtonContent(
                  text: "Riwayat Aduan",
                  color: const Color(0xFFD4AF37),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Tampilan Tombol (Isinya saja, animasinya di-handle _BouncingButton)
  Widget _buildBigButtonContent({required String text, required Color color}) {
    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
          fontFamily: 'Serif',
          shadows: [
            Shadow(offset: Offset(1, 1), color: Colors.black, blurRadius: 2),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// WIDGET ANIMASI: Bouncing Button
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
      duration: const Duration(milliseconds: 100), // Durasi animasi
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
      onTapDown: (_) => _controller.forward(), // Tekan: Menyusut
      onTapUp: (_) {
        _controller.reverse(); // Lepas: Kembali normal
        widget.onTap(); // Jalankan aksi
      },
      onTapCancel: () => _controller.reverse(), // Batal: Kembali normal
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}
