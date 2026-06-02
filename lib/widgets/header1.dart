import 'package:flutter/material.dart';
import '../models/homepage_config.dart';
import 'bdui/bdui_menu_grid.dart';
import 'custom_top_nav.dart';
import 'info_banner.dart';
import 'balance_card.dart';
import '../E_Wallet.dart';
import '../berita_promosi.dart';
import '../services/session_manager.dart';

class Header1 extends StatelessWidget {
  final HomepageConfig config;
  const Header1({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background Header Merah
          Container(
            height: 250,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF8B151A), Color(0xFF6B0B0C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header Bar
                const CustomTopNav(),

                // Greeting
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 30, right: 30),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text.rich(
                      TextSpan(
                        text: 'Selamat siang, ',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.normal, // tidak bold
                        ),
                        children: [
                          TextSpan(
                            text: '${SessionManager.currentUser?.name.toUpperCase() ?? 'NAYLA LARAS DAMAYANTI'} !',
                            style: const TextStyle(
                              fontWeight:
                                  FontWeight.bold, // bold hanya di nama
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Bagian Bawah Putih
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(
                        top: 65,
                      ), // Jarak agar Card utama bisa overlap
                      padding: const EdgeInsets.only(
                        top: 85,
                        left: 16,
                        right: 16,
                        bottom: 80,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Info Banner
                          const InfoBanner(),

                          const SizedBox(height: 24),

                          // Menu Grid & Tabs
                          BduiMenuGrid(prioritizedFeatures: config.features),

                          SizedBox(height: 30),

                          // e-Wallet Section
                          EWallet(),

                          SizedBox(height: 30),

                          // Bagian Berita & Promosi
                          BeritaPromosi(),
                        ],
                      ),
                    ),

                    // Floating Top Card (E-Wallet)
                    const Positioned(
                      top: 0,
                      left: 16,
                      right: 16,
                      child: BalanceCard(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
