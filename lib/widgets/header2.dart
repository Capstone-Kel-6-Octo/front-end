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
    final String formattedBalance = 'IDR ${balance.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}';
    final String userName = config.userName ?? 'User';

    return SingleChildScrollView(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ─── 1. BACKGROUND LAYER: Red Header + White Section (Drawn First) ───
          Column(
            children: [
              // Red Header Background
              Container(
                width: double.infinity,
                height: 230,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF8B151A), Color(0xFF5A0B0D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16), // Pushed down the logo / top nav
                      const CustomTopNav(),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Spacing to leave room for the floating QR card on the left
                            const SizedBox(width: 135),
                            const SizedBox(width: 16),
                            // Balance info pushed to the right side
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Selamat siang, $userName!',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Saldo OCTO Pay Anda',
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 10,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    formattedBalance,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
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
                    // Spacer for the floating QR Card and Mascot
                    const SizedBox(height: 100),



                    // ── Menu Grid ────────────────────────────────────────────
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

          // ─── 2. FOREGROUND LAYER: Floating QR Card & Mascot (Drawn Last on Top) ───
          Positioned(
            top: 135, // Floating overlapping boundary
            left: 20,
            right: 20,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // QR Code Card (Dominant on the Left)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFF8B151A).withOpacity(0.08),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9F9F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Image.asset(
                          'assets/Qr.png',
                          height: 95,
                          width: 95,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: 105,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B151A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Scan QRIS',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Mascot (Bottom Right)
                Expanded(
                  child: Container(
                    height: 135,
                    alignment: Alignment.bottomRight,
                    child: Image.asset(
                      'assets/octoheader2.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}