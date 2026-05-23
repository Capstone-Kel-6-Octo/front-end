import 'package:flutter/material.dart';
import 'custom_top_nav.dart';
import 'menu_grid_section.dart';
import 'balance_card.dart';
import '../E_Wallet.dart';
import '../berita_promosi.dart';

class Header3 extends StatelessWidget {
  const Header3({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
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
                          const CustomTopNav(),
                          const SizedBox(height: 20),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F2F2),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.asset(
                                  'assets/header3.png',
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      _buildExpenseRow('Shopping', Icons.shopping_bag, Colors.green.shade700, 'IDR 1,500,000', 0.6),
                                      const SizedBox(height: 12),
                                      _buildExpenseRow('Foods & Drinks', Icons.fastfood, Colors.orange.shade700, 'IDR 1,000,000', 0.4),
                                      const SizedBox(height: 12),
                                      _buildExpenseRow('Bill Payment', Icons.receipt_long, Colors.brown.shade600, 'IDR 800,000', 0.3),
                                      const SizedBox(height: 12),
                                      _buildExpenseRow('Transport', Icons.directions_car, Colors.red.shade900, 'IDR 975,000', 0.35),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: MenuGridSection(),
                ),
                const SizedBox(height: 30),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: BalanceCard(),
                ),
                const SizedBox(height: 30),
                const EWallet(),
                const SizedBox(height: 30),
                const BeritaPromosi(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseRow(String title, IconData icon, Color iconColor, String amount, double percent) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
        ),
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: percent,
                backgroundColor: Colors.grey.shade300,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8B151A)),
                minHeight: 6,
                borderRadius: BorderRadius.circular(4),
              )
            ],
          ),
        ),
      ],
    );
  }
}
