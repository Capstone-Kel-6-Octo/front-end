import 'package:flutter/material.dart';
import 'services/recommendation_service.dart';
import 'services/session_manager.dart';

class BeritaPromosi extends StatefulWidget {
  const BeritaPromosi({super.key});

  @override
  State<BeritaPromosi> createState() => _BeritaPromosiState();
}

class _BeritaPromosiState extends State<BeritaPromosi> {
  String _selectedTab = 'Semua';
  String _mlCluster = 'UNKNOWN';
  String _mlVersion = 'unknown';

  final List<String> _beritaList = [
    'assets/berita/Berita1.png',
    'assets/berita/Berita2.png',
    'assets/berita/Berita3.png',
  ];

  final List<String> _promosiList = [
    'assets/berita/Promosi1.png',
  ];

  @override
  void initState() {
    super.initState();
    _loadMLRecommendation();
  }

  Future<void> _loadMLRecommendation() async {
    try {
      final rec = await RecommendationService.fetchRecommendations();
      if (rec != null && mounted) {
        setState(() {
          _mlVersion = rec.mlVersion;
          _mlCluster = rec.config['cluster_label'] ?? 'UNKNOWN';
        });
      } else {
        // Fallback rule-based matching based on current user session
        final user = SessionManager.currentUser;
        if (user != null && mounted) {
          setState(() {
            _mlVersion = 'local-rule-v1';
            if (user.name.toLowerCase().contains('budi') || user.name.toLowerCase().contains('lead')) {
              _mlCluster = 'INVESTOR_SAVER';
            } else {
              _mlCluster = 'TRANSFER_HEAVY';
            }
          });
        }
      }
    } catch (e) {
      debugPrint('[BeritaPromosi] Gagal memuat rekomendasi ML: $e');
    }
  }

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

  Widget _buildDynamicPromoCard() {
    String title;
    String subtitle;
    String badge;
    String action;
    List<Color> colors;

    if (_mlCluster.toUpperCase() == 'INVESTOR_SAVER') {
      title = 'Optimalisasikan Deposito';
      subtitle = 'Imbal Hasil s/d 6.25% p.a.\nKhusus segmentasi tabungan Anda.';
      badge = 'OCTO-AI • INVESTOR';
      action = 'Mulai Investasi';
      colors = [const Color(0xFF0F172A), const Color(0xFF1E293B)]; // Premium dark slate AI style
    } else {
      title = 'Bebas Biaya Transfer';
      subtitle = 'Cashback QRIS 10% setiap hari\ndan gratis transfer tanpa batas.';
      badge = 'OCTO-AI • TRANSACTION';
      action = 'Klaim Voucher';
      colors = [const Color(0xFF8B151A), const Color(0xFF4A080A)]; // Premium Maroon CIMB
    }

    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 10),
                    const SizedBox(width: 4),
                    Text(
                      badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'ML: $_mlVersion',
                style: const TextStyle(color: Colors.white30, fontSize: 8, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Membuka penawaran personalisasi untuk $_mlCluster...'),
                  backgroundColor: const Color(0xFF10B981),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: colors[0],
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              action,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showDynamicCard = _selectedTab == 'Semua' || _selectedTab == 'Promosi';

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
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _currentImages.length + (showDynamicCard ? 1 : 0),
              itemBuilder: (context, index) {
                // Prepend the dynamic recommendation card if enabled
                if (showDynamicCard && index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: _buildDynamicPromoCard(),
                  );
                }

                // Adjust index for normal image assets
                final assetIndex = showDynamicCard ? index - 1 : index;

                return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      _currentImages[assetIndex],
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
