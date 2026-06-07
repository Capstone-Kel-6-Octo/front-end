import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/homepage_config.dart';
import '../../providers/homepage_provider.dart';
import '../../services/interaction_service.dart';
import '../../transfer_page.dart';

class BduiMenuGrid extends StatefulWidget {
  final List<FeatureItem> prioritizedFeatures;

  const BduiMenuGrid({
    super.key,
    required this.prioritizedFeatures,
  });

  @override
  State<BduiMenuGrid> createState() => _BduiMenuGridState();
}

class _BduiMenuGridState extends State<BduiMenuGrid> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tabs
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildTabItem('Untukmu (ML)', 0),
            _buildTabItem('Transaksi', 1),
            _buildTabItem('Produk', 2),
            _buildTabItem('Lainnya', 3),
          ],
        ),
        const SizedBox(height: 24),
        // Dynamic grids based on active tab
        if (_selectedTabIndex == 0)
          _buildGridUntukmuDynamic()
        else if (_selectedTabIndex == 1)
          _buildGridTransaksi()
        else if (_selectedTabIndex == 2)
          _buildGridProduk()
        else
          _buildGridLainnya(),
      ],
    );
  }

  Widget _buildTabItem(String title, int index) {
    final bool isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey.shade100 : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? const Color(0xFF8B151A) : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildGridItem({
    required int id,
    required String label,
    required String assetPath,
    bool showNewBadge = false,
    bool isBold = false,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          // Log interaction asynchronously in the background (Skenario 3)
          InteractionService.logInteraction(id, 'click');

          // Refresh homepage layout to see recommendation updates in real-time
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              Provider.of<HomepageProvider>(context, listen: false).fetchHomepage();
            }
          });

          if (id == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TransferPage()),
            );
            return;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Membuka Fitur $label...'),
              duration: const Duration(seconds: 2),
              backgroundColor: const Color(0xFF8B151A),
            ),
          );
        },
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  padding: const EdgeInsets.all(10),
                  child: Image.asset(assetPath, fit: BoxFit.contain),
                ),
                if (showNewBadge)
                  Positioned(
                    top: -6,
                    left: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'NEW',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: Colors.black87,
                height: 1.2,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyGridItem() {
    return const Expanded(child: SizedBox());
  }

  Widget _buildGridUntukmuDynamic() {
    // 1. Definisikan semua item yang tersedia (total 10 item)
    final Map<String, Widget> allAvailableItems = {
      'transfer': _buildGridItem(id: 1, label: 'Transfer', assetPath: 'assets/home/Transfer.png'),
      'top_up': _buildGridItem(id: 2, label: 'Tagihan &\nIsi Ulang', assetPath: 'assets/home/Tagihan.png'),
      'investasi': _buildGridItem(id: 3, label: 'Investasi', assetPath: 'assets/home/Investasi.png'),
      'pembayaran': _buildGridItem(id: 4, label: 'Verify With\nOCTO', assetPath: 'assets/home/VerifiyOcto.png'),
      'payroll': _buildGridItem(id: 5, label: 'Tabungan &\nDeposito', assetPath: 'assets/home/TabunganDeposito.png'),
      'transaksi_tanpa_kartu': _buildGridItem(id: 99, label: 'Transaksi\nTanpa Kartu', assetPath: 'assets/home/TransaksiTanpaKartu.png'),
      'kartu_elektronik': _buildGridItem(id: 98, label: 'Kartu\nElektronik', assetPath: 'assets/home/KartuElektronik.png'),
      'jadwal_saya': _buildGridItem(id: 97, label: 'Jadwal Saya', assetPath: 'assets/home/JadwalSaya.png'),
      'kode_promo': _buildGridItem(id: 96, label: 'Kode Promo', assetPath: 'assets/home/KodePromo.png'),
      'adjust_favorite': _buildGridItem(id: 95, label: 'Adjust\nFavorite', assetPath: 'assets/home/AdjustFavorite.png', isBold: true),
    };

    final List<Widget> dynamicItems = [];
    final Set<String> addedKeys = {};

    // 2. Tambahkan item yang diprioritaskan oleh ML/Backend
    for (var feat in widget.prioritizedFeatures) {
      String key = feat.name.toLowerCase().trim();
      
      // Sinkronisasi alias nama fitur dari ML/Backend jika ada beda penamaan
      if (key == 'top up' || key == 'topup' || key == 'tagihan_dan_isi_ulang' || key == 'tagihan_isi_ulang') {
        key = 'top_up';
      } else if (key == 'verify_with_octo') {
        key = 'pembayaran';
      } else if (key == 'tabungan_deposito') {
        key = 'payroll';
      }

      // Normalisasi spasi ke underscore untuk mencocokkan key map
      key = key.replaceAll(' ', '_');

      if (allAvailableItems.containsKey(key) && !addedKeys.contains(key)) {
        dynamicItems.add(allAvailableItems[key]!);
        addedKeys.add(key);
      }
    }

    // 3. Tambahkan item sisa yang belum dimasukkan agar total tetap 10 item
    // Urutan default sisa jika tidak disortir oleh ML
    final List<String> defaultOrder = [
      'transfer',
      'top_up',
      'transaksi_tanpa_kartu',
      'kartu_elektronik',
      'pembayaran',
      'jadwal_saya',
      'investasi',
      'kode_promo',
      'payroll',
      'adjust_favorite',
    ];

    for (var key in defaultOrder) {
      final normalizedKey = key.replaceAll(' ', '_');
      if (!addedKeys.contains(normalizedKey) && allAvailableItems.containsKey(normalizedKey)) {
        dynamicItems.add(allAvailableItems[normalizedKey]!);
        addedKeys.add(normalizedKey);
      }
    }

    // Pastikan panjang list tepat 10 item (2 baris x 5 kolom)
    while (dynamicItems.length < 10) {
      dynamicItems.add(_buildEmptyGridItem());
    }

    final firstRow = dynamicItems.sublist(0, 5);
    final secondRow = dynamicItems.sublist(5, 10);

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: firstRow,
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: secondRow,
        ),
      ],
    );
  }

  Widget _buildGridTransaksi() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildGridItem(id: 1, label: 'Transfer', assetPath: 'assets/home/Transfer.png'),
            _buildGridItem(id: 2, label: 'Tagihan &\nIsi Ulang', assetPath: 'assets/home/Tagihan.png'),
            _buildGridItem(id: 99, label: 'Transaksi\nTanpa Kartu', assetPath: 'assets/home/TransaksiTanpaKartu.png'),
            _buildEmptyGridItem(),
            _buildEmptyGridItem(),
          ],
        ),
      ],
    );
  }

  Widget _buildGridProduk() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildGridItem(id: 5, label: 'Tabungan &\nDeposito', assetPath: 'assets/home/TabunganDeposito.png'),
            _buildGridItem(id: 98, label: 'Kartu\nElektronik', assetPath: 'assets/home/KartuElektronik.png'),
            _buildGridItem(id: 3, label: 'Investasi', assetPath: 'assets/home/Investasi.png'),
            _buildEmptyGridItem(),
            _buildEmptyGridItem(),
          ],
        ),
      ],
    );
  }

  Widget _buildGridLainnya() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildGridItem(id: 97, label: 'Jadwal Saya', assetPath: 'assets/home/JadwalSaya.png'),
            _buildGridItem(id: 96, label: 'Kode Promo', assetPath: 'assets/home/KodePromo.png'),
            _buildGridItem(id: 4, label: 'Verify With\nOCTO', assetPath: 'assets/home/VerifiyOcto.png'),
            _buildGridItem(id: 95, label: 'Adjust\nFavorite', assetPath: 'assets/home/AdjustFavorite.png', isBold: true),
            _buildEmptyGridItem(),
          ],
        ),
      ],
    );
  }
}
