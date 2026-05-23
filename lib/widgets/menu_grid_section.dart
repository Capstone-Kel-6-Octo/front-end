import 'package:flutter/material.dart';

class MenuGridSection extends StatefulWidget {
  const MenuGridSection({super.key});

  @override
  State<MenuGridSection> createState() => _MenuGridSectionState();
}

class _MenuGridSectionState extends State<MenuGridSection> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tabs
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildTabItem('Untukmu', 0),
            _buildTabItem('Transaksi', 1),
            _buildTabItem('Produk', 2),
            _buildTabItem('Lainnya', 3),
          ],
        ),
        const SizedBox(height: 24),
        // Menus Grid
        if (_selectedTabIndex == 0)
          _buildGridUntukmu()
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey.shade100 : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? const Color(0xFF8B151A) : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildGridItem(
    String label, {
    IconData? icon,
    String? assetPath,
    Color iconColor = const Color(0xFF8B151A),
    Color iconBgColor = Colors.transparent,
    bool showNewBadge = false,
    bool isBold = false,
  }) {
    return Expanded(
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 50,
                height: 50,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: iconBgColor != Colors.transparent
                      ? BoxShape.circle
                      : BoxShape.rectangle,
                ),
                child: assetPath != null
                    ? Image.asset(assetPath, fit: BoxFit.contain)
                    : (icon != null
                        ? Icon(icon, color: iconColor, size: 30)
                        : null),
              ),
              if (showNewBadge)
                Positioned(
                  top: -6,
                  left: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
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
    );
  }

  Widget _buildEmptyGridItem() {
    return const Expanded(child: SizedBox());
  }

  Widget _buildGridUntukmu() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildGridItem('Transfer', assetPath: 'assets/home/Transfer.png'),
            _buildGridItem('Tagihan &\nIsi Ulang',
                assetPath: 'assets/home/Tagihan.png'),
            _buildGridItem('Transaksi\nTanpa Kartu',
                assetPath: 'assets/home/TransaksiTanpaKartu.png'),
            _buildGridItem('Kartu\nElektronik',
                assetPath: 'assets/home/KartuElektronik.png'),
            _buildGridItem('Verify With\nOCTO',
                assetPath: 'assets/home/VerifiyOcto.png'),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildGridItem('Jadwal Saya',
                assetPath: 'assets/home/JadwalSaya.png'),
            _buildGridItem('Investasi', assetPath: 'assets/home/Investasi.png'),
            _buildGridItem('Kode Promo',
                assetPath: 'assets/home/KodePromo.png'),
            _buildGridItem('Tabungan &\nDeposito',
                assetPath: 'assets/home/TabunganDeposito.png'),
            _buildGridItem('Adjust\nFavorite',
                assetPath: 'assets/home/AdjustFavorite.png', isBold: true),
          ],
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
            _buildGridItem('Transfer', assetPath: 'assets/home/Transfer.png'),
            _buildGridItem('Tagihan &\nIsi Ulang',
                assetPath: 'assets/home/Tagihan.png'),
            _buildGridItem('Transaksi\nTanpa Kartu',
                assetPath: 'assets/home/TransaksiTanpaKartu.png'),
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
            _buildGridItem('Tabungan &\nDeposito',
                assetPath: 'assets/home/TabunganDeposito.png'),
            _buildGridItem('Kartu\nElektronik',
                assetPath: 'assets/home/KartuElektronik.png'),
            _buildGridItem('Investasi', assetPath: 'assets/home/Investasi.png'),
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
            _buildGridItem('Jadwal Saya',
                assetPath: 'assets/home/JadwalSaya.png'),
            _buildGridItem('Kode Promo',
                assetPath: 'assets/home/KodePromo.png'),
            _buildGridItem('Verify With\nOCTO',
                assetPath: 'assets/home/VerifiyOcto.png'),
            _buildGridItem('Adjust\nFavorite',
                assetPath: 'assets/home/AdjustFavorite.png', isBold: true),
            _buildEmptyGridItem(),
          ],
        ),
      ],
    );
  }
}
