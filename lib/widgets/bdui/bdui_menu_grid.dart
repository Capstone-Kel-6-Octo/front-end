import 'package:flutter/material.dart';
import '../../models/homepage_config.dart';
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
    // Map backend features database attributes:
    // 1 -> Transfer, 2 -> Top Up, 3 -> Investasi, 4 -> Pembayaran, 5 -> Payroll
    final List<Widget> dynamicItems = [];

    for (var feat in widget.prioritizedFeatures) {
      switch (feat.name.toLowerCase()) {
        case 'transfer':
          dynamicItems.add(_buildGridItem(id: 1, label: 'Transfer', assetPath: 'assets/home/Transfer.png'));
          break;
        case 'top up':
        case 'topup':
          dynamicItems.add(_buildGridItem(id: 2, label: 'Tagihan &\nIsi Ulang', assetPath: 'assets/home/Tagihan.png'));
          break;
        case 'investasi':
          dynamicItems.add(_buildGridItem(id: 3, label: 'Investasi', assetPath: 'assets/home/Investasi.png'));
          break;
        case 'pembayaran':
          dynamicItems.add(_buildGridItem(id: 4, label: 'Verify With\nOCTO', assetPath: 'assets/home/VerifiyOcto.png'));
          break;
        case 'payroll':
          dynamicItems.add(_buildGridItem(id: 5, label: 'Tabungan &\nDeposito', assetPath: 'assets/home/TabunganDeposito.png'));
          break;
      }
    }

    // Add static items to make a total of 10 items (2 rows of 5)
    // Add missing standard items if they are not in the dynamic list
    final List<Widget> standardFavs = [
      _buildGridItem(id: 99, label: 'Transaksi\nTanpa Kartu', assetPath: 'assets/home/TransaksiTanpaKartu.png'),
      _buildGridItem(id: 98, label: 'Kartu\nElektronik', assetPath: 'assets/home/KartuElektronik.png'),
      _buildGridItem(id: 97, label: 'Jadwal Saya', assetPath: 'assets/home/JadwalSaya.png'),
      _buildGridItem(id: 96, label: 'Kode Promo', assetPath: 'assets/home/KodePromo.png'),
      _buildGridItem(id: 95, label: 'Adjust\nFavorite', assetPath: 'assets/home/AdjustFavorite.png', isBold: true),
    ];

    final List<Widget> allGridItems = [...dynamicItems, ...standardFavs];

    // Ensure we have exactly 10 grid spaces (2 rows of 5)
    while (allGridItems.length < 10) {
      allGridItems.add(_buildEmptyGridItem());
    }

    final firstRow = allGridItems.sublist(0, 5);
    final secondRow = allGridItems.sublist(5, 10);

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
