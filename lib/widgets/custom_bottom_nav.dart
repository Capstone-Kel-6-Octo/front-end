import 'package:flutter/material.dart';
import '../home_page.dart';
import '../my_account_page.dart';
import '../wealth_page.dart';
import '../settings_page.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNav({super.key, this.currentIndex = 0});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        BottomAppBar(
          color: Colors.white,
          surfaceTintColor: Colors.white,
          shadowColor: Colors.black,
          elevation: 10,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          child: SizedBox(
            height: 70, // tinggi navbar
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context,
                  'Home',
                  0,
                  assetPath: 'assets/navbar/Home.png',
                  activeAssetPath: 'assets/navbar/HomeActive.png',
                ),
                _buildNavItem(
                  context,
                  'My Account',
                  1,
                  assetPath: 'assets/navbar/account.png',
                  activeAssetPath: 'assets/navbar/AccountActive.png',
                ),
                // Ruang kosong untuk tombol QRIS yang mengambang
                const SizedBox(width: 65),
                _buildNavItem(
                  context,
                  'Wealth',
                  2,
                  assetPath: 'assets/navbar/WealthLogo.png',
                  activeAssetPath: 'assets/navbar/WealthActive.png',
                ),
                _buildNavItem(
                  context,
                  'Settings',
                  3,
                  assetPath: 'assets/navbar/setting.png',
                  activeAssetPath: 'assets/navbar/SettingsActive.png',
                ),
              ],
            ),
          )
        ),
        Positioned(
          top: -24, // Posisi statis tepat di tengah lekukan notch
          child: const QrisFloatingButton(),
        ),
      ],
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    String label,
    int index, {
    IconData? icon,
    String? assetPath,
    String? activeAssetPath,
  }) {
    final bool isSelected = currentIndex == index;
    final Color color = isSelected
        ? const Color(0xFFC7161C)
        : Colors.grey.shade500;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (index == currentIndex) return;

        Widget? page;
        switch (index) {
          case 0:
            page = const HomePage();
            break;
          case 1:
            page = const MyAccountPage();
            break;
          case 2:
            page = const WealthPage();
            break;
          case 3:
            page = const SettingsPage();
            break;
        }

        if (page != null) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => page!,
              transitionDuration: Duration.zero,
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (assetPath != null)
              Image.asset(
                (isSelected && activeAssetPath != null) ? activeAssetPath : assetPath,
                width: 28,
                height: 28,
              )
            else if (icon != null)
              Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QrisFloatingButton extends StatelessWidget {
  const QrisFloatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFB11216), // Merah pekat sesuai gambar
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {},
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: const Text(
                  'Pay',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    height: 1.0, // Mengurangi jarak internal font
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(
                  0,
                  -4,
                ), // Menaikkan posisi gambar sedikit agar lebih rapat
                child: Image.asset(
                  'assets/navbar/qris_putih 1.png',
                  width: 42,
                  height: 42,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
