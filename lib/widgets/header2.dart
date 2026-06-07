import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/homepage_config.dart';
import '../providers/transaction_provider.dart';
import 'bdui/bdui_menu_grid.dart';
import 'custom_top_nav.dart';
import '../E_Wallet.dart';
import '../berita_promosi.dart';

class Header2 extends StatelessWidget {
  final HomepageConfig config;
  const Header2({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    final txProvider = Provider.of<TransactionProvider>(context);
    final double balance = txProvider.octoPayBalance;
    final String formattedBalance =
        'IDR ${balance.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}';
    final String userName = config.userName ?? 'User';

    const double redHeaderHeight = 210.0;
    const double cardOverlapTop = 90.0;
    const double qrCardWidth = 168.0;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── BACKGROUND LAYER ─────────────────────────────────────────
          Column(
            children: [
              // Red Header
              Container(
                width: double.infinity,
                height: redHeaderHeight,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B151A), Color(0xFF5A0B0D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      const CustomTopNav(),
                    ],
                  ),
                ),
              ),

              // White Content Section
              Container(
                color: Colors.white,
                width: double.infinity,
                child: Column(
                  children: [
                    const SizedBox(height: 135),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: BduiMenuGrid(prioritizedFeatures: config.features),
                    ),
                    const SizedBox(height: 24),
                    const EWallet(),
                    const SizedBox(height: 24),
                    const BeritaPromosi(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),

          // ── FOREGROUND LAYER (QR Card & Greeting) ────────────────────
          Positioned(
            top: cardOverlapTop,
            left: 16,
            right: 16,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── QR Card (Kiri, Dominan) ───────────────────────────
                Container(
                  width: qrCardWidth,
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // QR Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'assets/Qr.png',
                          height: 140,
                          width: 140,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Scan QRIS Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B151A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Scan QRIS',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 28),

                // ── Kanan: Greeting & Balance ───────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        'Selamat siang, $userName!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Saldo OCTO Pay Anda',
                        style: TextStyle(
                          color: Color(0xFFE57373),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        formattedBalance,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Mascot (Kanan, Overlapping Red and White) ──────────────────
          Positioned(
            top: 185.0,
            right: 40,
            child: Image.asset(
              'assets/octoheader2.png',
              height: 170,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}