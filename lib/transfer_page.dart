import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/transaction_provider.dart';
import 'services/transaction_service.dart';

class TransferPage extends StatefulWidget {
  const TransferPage({super.key});

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  final _formKey = GlobalKey<FormState>();
  final _receiverController = TextEditingController();
  final _amountController = TextEditingController();

  bool _isSearchingRecipient = false;
  String? _recipientName;
  String? _recipientError;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _receiverController.addListener(_onReceiverIdChanged);
  }

  @override
  void dispose() {
    _receiverController.removeListener(_onReceiverIdChanged);
    _receiverController.dispose();
    _amountController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onReceiverIdChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    final input = _receiverController.text.trim();
    if (input.isEmpty) {
      setState(() {
        _recipientName = null;
        _recipientError = null;
        _isSearchingRecipient = false;
      });
      return;
    }

    final userId = int.tryParse(input);
    if (userId == null) {
      setState(() {
        _recipientName = null;
        _recipientError = 'ID Penerima harus berupa angka';
        _isSearchingRecipient = false;
      });
      return;
    }

    setState(() {
      _isSearchingRecipient = true;
      _recipientName = null;
      _recipientError = null;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 600), () async {
      try {
        final name = await TransactionService.fetchRecipientName(userId);
        if (mounted) {
          setState(() {
            _recipientName = name;
            _recipientError = null;
            _isSearchingRecipient = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _recipientName = null;
            _recipientError = 'Penerima tidak ditemukan';
            _isSearchingRecipient = false;
          });
        }
      }
    });
  }

  void _quickSelectAmount(double amount) {
    setState(() {
      _amountController.text = amount.toStringAsFixed(0);
    });
  }

  Future<void> _submitTransfer() async {
    if (!_formKey.currentState!.validate()) return;
    if (_recipientName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tolong pastikan ID Penerima valid terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final receiverId = int.parse(_receiverController.text.trim());
    final amount = double.parse(_amountController.text.trim());
    final txProvider = Provider.of<TransactionProvider>(context, listen: false);

    if (txProvider.octoPayBalance < amount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saldo OCTO Pay Anda tidak mencukupi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Tampilkan konfirmasi Bottom Sheet premium
    final confirmed = await showModalBottomSheet<bool>(
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
              const Text(
                'Konfirmasi Transfer',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B151A),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              _buildConfirmRow('Penerima', '$_recipientName (ID: $receiverId)'),
              const SizedBox(height: 12),
              _buildConfirmRow(
                'Jumlah Transfer',
                'IDR ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}',
                isAmount: true,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B151A),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Konfirmasi',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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

    if (confirmed != true) return;

    // Tampilkan Loading Overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF8B151A)),
      ),
    );

    try {
      final success = await txProvider.performTransfer(
        receiverId: receiverId,
        amount: amount,
      );

      // Tutup loading
      if (mounted) Navigator.pop(context);

      if (success) {
        // Tampilkan Sukses Overlay
        if (mounted) {
          _showSuccessPage(receiverId, _recipientName!, amount);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal melakukan transfer dana. Coba lagi.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Tutup loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSuccessPage(int receiverId, String name, double amount) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF8B151A), Color(0xFF5E0B0E)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline_rounded,
                    color: Colors.white,
                    size: 80,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Transfer Berhasil!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Saldo Anda telah dikirimkan ke penerima',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 40),
                // Slip Resi
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildReceiptRow('Penerima', name),
                      const SizedBox(height: 8),
                      _buildReceiptRow('ID Penerima', receiverId.toString()),
                      const SizedBox(height: 8),
                      _buildReceiptRow(
                        'Jumlah',
                        'IDR ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}',
                        boldValue: true,
                      ),
                      const SizedBox(height: 8),
                      _buildReceiptRow('Tanggal', DateTime.now().toString().split('.')[0]),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF8B151A),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Kembali ke Beranda',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmRow(String label, String value, {bool isAmount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        Text(
          value,
          style: TextStyle(
            color: isAmount ? const Color(0xFF8B151A) : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: isAmount ? 16 : 14,
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool boldValue = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.black87,
            fontWeight: boldValue ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final txProvider = Provider.of<TransactionProvider>(context);
    final String balanceText =
        'IDR ${txProvider.octoPayBalance.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}';

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        title: const Text(
          'Transfer OCTO Pay',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF8B151A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Maroon Header Info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              decoration: const BoxDecoration(
                color: Color(0xFF8B151A),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Saldo OCTO Pay Anda',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    balanceText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Form Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ID Penerima',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _receiverController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          hintText: 'Masukkan ID akun tujuan',
                          prefixIcon: const Icon(Icons.person_outline_rounded, color: Color(0xFF8B151A)),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Color(0xFF8B151A), width: 1.5),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Tolong masukkan ID Penerima';
                          }
                          return null;
                        },
                      ),
                      // Lookup Feedback
                      if (_isSearchingRecipient)
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0, left: 4.0),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF8B151A)),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Mencari penerima...',
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        )
                      else if (_recipientName != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.green, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'Penerima: $_recipientName',
                                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
                          ),
                        )
                      else if (_recipientError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                          child: Row(
                            children: [
                              const Icon(Icons.error_rounded, color: Colors.red, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                _recipientError!,
                                style: const TextStyle(color: Colors.red, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 20),
                      const Text(
                        'Nominal Transfer (IDR)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          hintText: 'Masukkan nominal',
                          prefixIcon: const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF8B151A)),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Color(0xFF8B151A), width: 1.5),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Tolong masukkan nominal transfer';
                          }
                          final amt = double.tryParse(value);
                          if (amt == null || amt <= 0) {
                            return 'Nominal transfer harus lebih dari 0';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Quick Select Chips
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildQuickAmountChip(50000, '50rb'),
                          _buildQuickAmountChip(100000, '100rb'),
                          _buildQuickAmountChip(250000, '250rb'),
                          _buildQuickAmountChip(500000, '500rb'),
                        ],
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSearchingRecipient ? null : _submitTransfer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B151A),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Kirim Transfer',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAmountChip(double value, String label) {
    return GestureDetector(
      onTap: () => _quickSelectAmount(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF8B151A).withOpacity(0.06),
          border: Border.all(color: const Color(0xFF8B151A).withOpacity(0.15)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8B151A),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
