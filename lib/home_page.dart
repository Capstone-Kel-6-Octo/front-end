import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/homepage_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/consent_provider.dart';
import 'services/session_manager.dart';
import 'widgets/bdui/bdui_renderer.dart';
import 'widgets/custom_bottom_nav.dart';
import 'widgets/info_banner.dart';
import 'widgets/header1.dart';
import 'widgets/header2.dart';
import 'widgets/header3.dart';
import 'E_Wallet.dart';
import 'berita_promosi.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Fetch backend-driven homepage configuration upon screen startup
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final homeProvider = Provider.of<HomepageProvider>(context, listen: false);
      final txProvider = Provider.of<TransactionProvider>(context, listen: false);
      final consentProvider = Provider.of<ConsentProvider>(context, listen: false);

      // 1. Fetch Dynamic BDUI menus
      await homeProvider.fetchHomepage();

      // 2. Fetch Transaction mutations & balance
      await txProvider.fetchTransactions();

      // 3. Sinkronisasi data user dari response homepage jika ada setelah fetchTransactions
      if (homeProvider.config != null) {
        final config = homeProvider.config!;
        if (config.userName != null && SessionManager.currentUser != null) {
          SessionManager.currentUser = UserModel(
            id: SessionManager.currentUser!.id,
            name: config.userName!,
            email: SessionManager.currentUser!.email,
            role: SessionManager.currentUser!.role,
          );
        }
        if (config.userBalance != null) {
          txProvider.updateBalance(config.userBalance!);
        }
      }

      // 4. Fetch Legal consent & show popup dialog if not done yet
      await consentProvider.fetchConsentState();
      
      if (!consentProvider.hasCheckedConsent) {
        _showConsentBottomSheet();
      }
    });
  }

  void _showConsentBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B151A).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.security_rounded,
                      color: Color(0xFF8B151A),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'Personalisasi Layanan AI',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Bantu OCTO Mobile memahami preferensi Anda! Dengan menyetujui pembagian data analitik, model kecerdasan buatan (Machine Learning) kami akan menyusun menu beranda dan merekomendasikan produk finansial yang paling sesuai untuk gaya hidup Anda secara real-time.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Provider.of<ConsentProvider>(context, listen: false)
                            .createInitialConsent(false);
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: const BorderSide(color: Colors.grey),
                      ),
                      child: const Text(
                        'Lewati',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Provider.of<ConsentProvider>(context, listen: false)
                            .createInitialConsent(true);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B151A),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Setuju & Aktifkan',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
      floatingActionButton: const SizedBox(width: 68, height: 68),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: Consumer<HomepageProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return _buildLoadingState();
          }

          if (provider.errorMessage != null) {
            return _buildErrorState(
              provider.errorMessage!,
              () => provider.retryFetch(),
            );
          }

          if (provider.config == null) {
            return _buildErrorState(
              'Gagal mendapatkan konfigurasi dari server.',
              () => provider.retryFetch(),
            );
          }

          // RENDER DYNAMIC HEADER LAYOUT BASED ON USER PERSONA ROLE
final config = provider.config!;
return Header2(config: config); // Dipaksa selalu merender Header 2

        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF8B151A), Color(0xFF6B0B0C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.white,
            ),
            SizedBox(height: 16),
            Text(
              'Menyusun Beranda Personal Anda...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message, VoidCallback onRetry) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF8B151A), Color(0xFF6B0B0C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              color: Colors.white,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Gagal Memuat Beranda',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, color: Color(0xFF8B151A)),
              label: const Text(
                'Coba Lagi',
                style: TextStyle(
                  color: Color(0xFF8B151A),
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
