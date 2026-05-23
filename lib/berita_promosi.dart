import 'package:flutter/material.dart';

class BeritaPromosi extends StatefulWidget {
  const BeritaPromosi({super.key});

  @override
  State<BeritaPromosi> createState() => _BeritaPromosiState();
}

class _BeritaPromosiState extends State<BeritaPromosi> {
  String _selectedTab = 'Semua';

  final List<String> _beritaList = [
    'assets/berita/Berita1.png',
    'assets/berita/Berita2.png',
    'assets/berita/Berita3.png',
  ];

  final List<String> _promosiList = [
    'assets/berita/Promosi1.png',
  ];

  List<String> get _currentImages {
    if (_selectedTab == 'Semua') {
      return [..._beritaList, ..._promosiList];
    } else if (_selectedTab == 'Promosi') {
      return _promosiList;
    } else {
      return _beritaList;
    }
  }

  Widget _buildTab(String title) {
    bool isSelected = _selectedTab == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = title;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: const Color(0xFF8B151A), width: 1.5)
              : Border.all(color: Colors.transparent),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? const Color(0xFF8B151A) : Colors.grey.shade400,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 24, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Berita & Promosi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildTab('Semua'),
                const SizedBox(width: 8),
                _buildTab('Promosi'),
                const SizedBox(width: 8),
                _buildTab('Berita'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180, // Adjust this height depending on the banner aspect ratio
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _currentImages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      _currentImages[index],
                      fit: BoxFit.cover,
                      height: 180,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
