import 'package:flutter/material.dart';
import 'location_page.dart';
import 'family_page.dart';
import 'jam_tangan_page.dart';

class MainNavigationPage extends StatefulWidget {
  final int initialIndex;
  
  const MainNavigationPage({
    Key? key, 
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          LocationPage(isInMainNavigation: true),
          FamilyPage(isInMainNavigation: true),
          JamTanganPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFFE07B4F),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Lokasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Keluarga',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Jam Tangan',
          ),
        ],
      ),
    );
  }
}
