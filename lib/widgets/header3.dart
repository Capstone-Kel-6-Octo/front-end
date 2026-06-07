import 'package:flutter/material.dart';
import '../models/homepage_config.dart';
import 'bdui/bdui_menu_grid.dart';
import 'custom_top_nav.dart';
import 'balance_card.dart';
import '../E_Wallet.dart';
import '../berita_promosi.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';

class Header3 extends StatelessWidget {
  final HomepageConfig config;
  const Header3({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    final txProvider = Provider.of<TransactionProvider>(context);
    final double balance = txProvider.octoPayBalance;
    final String formattedBalance = 'IDR ${balance.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}';

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
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                )
                              ],
                              border: Border.all(
                                color: const Color(0xFF8B151A).withOpacity(0.12),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // TOP SECTION: Title, Amount, and Saving Jar Image
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF8B151A).withOpacity(0.08),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: const Text(
                                              'PRIORITAS FINANCE',
                                              style: TextStyle(
                                                color: Color(0xFF8B151A),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10,
                                                letterSpacing: 1.2,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          const Text(
                                            'Ringkasan Pengeluaran',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const Text(
                                            'Bulan Ini',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.black54,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            formattedBalance,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 24,
                                              color: Color(0xFF8B151A),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Image.asset(
                                      'assets/home/money saving 1.png',
                                      height: 125,
                                      fit: BoxFit.contain,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Divider(
                                  color: Colors.grey.shade100,
                                  thickness: 1.5,
                                ),
                                const SizedBox(height: 16),
                                // BOTTOM SECTION: Category Progress Bars
                                _buildExpenseRow('Shopping', Icons.shopping_bag_outlined, Colors.green.shade700, 'IDR 1,500,000', 0.6),
                                const SizedBox(height: 16),
                                _buildExpenseRow('Foods & Drinks', Icons.fastfood_outlined, Colors.orange.shade700, 'IDR 1,000,000', 0.4),
                                const SizedBox(height: 16),
                                _buildExpenseRow('Bill Payment', Icons.receipt_long_outlined, Colors.blue.shade700, 'IDR 800,000', 0.3),
                                const SizedBox(height: 16),
                                _buildExpenseRow('Transport', Icons.directions_car_outlined, Colors.red.shade700, 'IDR 975,000', 0.35),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: BduiMenuGrid(prioritizedFeatures: config.features),
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

  Widget _buildExpenseRow(String title, IconData icon, Color categoryColor, String amount, double percent) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: categoryColor.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: categoryColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    amount,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percent,
                  backgroundColor: Colors.grey.shade100,
                  valueColor: AlwaysStoppedAnimation<Color>(categoryColor),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
