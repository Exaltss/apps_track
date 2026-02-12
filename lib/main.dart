import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/aduan_page.dart';
import 'pages/history_menu_page.dart';
import 'pages/map_page.dart';
import 'pages/profile_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Patrol App',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF151B25), // Dark Background
        fontFamily: 'Roboto',
        useMaterial3: true,
        // Konfigurasi tema umum untuk Text Field agar seragam
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2C3542),
          hintStyle: TextStyle(color: Colors.grey[500]),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Daftar halaman untuk setiap tab navigasi
  final List<Widget> _pages = [
    const HomePage(),
    const AduanPage(), // Icon ke-2 (Formulir/Aduan)
    const HistoryMenuPage(), // Icon ke-3 (Riwayat)
    const MapPage(), // Icon ke-4 (Peta)
    const ProfilePage(), // Icon ke-5 (Profil)
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1F2936),
        selectedItemColor: Colors.yellow,
        unselectedItemColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 30),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description, size: 30),
            label: 'Aduan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history, size: 30),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on, size: 30),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 30),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
