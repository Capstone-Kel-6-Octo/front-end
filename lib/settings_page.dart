import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/session_manager.dart';
import '../services/user_service.dart';
import '../providers/consent_provider.dart';
import 'widgets/custom_bottom_nav.dart';
import 'login_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = SessionManager.currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
    }
    // Fetch latest consent state on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ConsentProvider>(context, listen: false).fetchConsentState();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _handleLogout() {
    SessionManager.clearSession();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  Future<void> _handleSaveProfile() async {
    if (_nameController.text.trim().isEmpty || _emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kolom Nama dan Email wajib diisi!'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await UserService.updateUserProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui di server PostgreSQL!'), backgroundColor: Color(0xFF10B981)),
      );

      setState(() {
        _isEditing = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = SessionManager.currentUser;
    final initials = user != null && user.name.isNotEmpty
        ? user.name.split(' ').map((n) => n[0]).join('').substring(0, 1).toUpperCase()
        : 'U';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 3),
      floatingActionButton: const SizedBox(width: 68, height: 68),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: Consumer<ConsentProvider>(
        builder: (context, consentProvider, child) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Premium Settings Header
                Container(
                  padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Pengaturan',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.black87,
                            ),
                          ),
                          if (!_isEditing)
                            TextButton.icon(
                              onPressed: () => setState(() => _isEditing = true),
                              icon: const Icon(Icons.edit_rounded, size: 16, color: Color(0xFF8B151A)),
                              label: const Text('Edit Profil', style: TextStyle(color: Color(0xFF8B151A), fontWeight: FontWeight.bold)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                              color: Color(0xFF8B151A),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                initials,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _isEditing
                                ? Column(
                                    children: [
                                      TextField(
                                        controller: _nameController,
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          labelText: 'Nama Lengkap',
                                          labelStyle: TextStyle(fontSize: 11),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextField(
                                        controller: _emailController,
                                        style: const TextStyle(fontSize: 14),
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          labelText: 'Email Resmi',
                                          labelStyle: TextStyle(fontSize: 11),
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user?.name ?? 'Admin User',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        user?.email ?? 'admin@octo.com',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'User ID: ${user?.id ?? "-"}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF8B151A),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                      if (_isEditing)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    _isEditing = false;
                                    // Reset values
                                    if (user != null) {
                                      _nameController.text = user.name;
                                      _emailController.text = user.email;
                                    }
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: _isSaving ? null : _handleSaveProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF8B151A),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  elevation: 0,
                                ),
                                child: _isSaving
                                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : const Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // AI Personalization Consent Settings Block
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'AI & PERSONALISASI',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SwitchListTile(
                    activeColor: const Color(0xFF8B151A),
                    value: consentProvider.consentGiven,
                    onChanged: (bool value) {
                      consentProvider.toggleConsent(value);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            value
                                ? 'Persetujuan data personalisasi AI AKTIF.'
                                : 'Persetujuan data personalisasi AI DINONAKTIFKAN.',
                          ),
                          backgroundColor: value ? const Color(0xFF10B981) : Colors.black87,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    title: const Text(
                      'Personalisasi AI Beranda',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text(
                      'Izinkan model ML mengklasifikasikan kebutuhan prioritas menu dan merekomendasikan promo yang cocok.',
                      style: TextStyle(fontSize: 10, color: Colors.grey, height: 1.3),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Sign Out Block
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: _handleLogout,
                      icon: const Icon(Icons.logout_rounded, color: Color(0xFF8B151A)),
                      label: const Text(
                        'Keluar Sesi Akun',
                        style: TextStyle(
                          color: Color(0xFF8B151A),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF8B151A), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 120),
              ],
            ),
          );
        },
      ),
    );
  }
}
