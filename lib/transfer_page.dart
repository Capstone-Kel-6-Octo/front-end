import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/transaction_provider.dart';
import 'services/transaction_service.dart';
import 'widgets/pin_verification_sheet.dart';
import 'transfer_success_page.dart';

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

  String _formatNumber(String s) {
    String clean = s.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.isEmpty) return '';
    final buffer = StringBuffer();
    int digitsCount = clean.length;
    for (int i = 0; i < digitsCount; i++) {
      buffer.write(clean[i]);
      int remaining = digitsCount - 1 - i;
      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write(',');
      }
    }
    return buffer.toString();
  }

  void _quickSelectAmount(double amount) {
    setState(() {
      _amountController.text = _formatNumber(amount.toStringAsFixed(0));
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
    final amount = double.parse(_amountController.text.replaceAll(',', '').trim());

    if (amount < 10000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimal transfer adalah IDR 10,000'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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

    // Tampilkan PIN Verification Sheet
    if (!mounted) return;
    final pinVerified = await PinVerificationSheet.show(context);
    if (pinVerified != true) return;

    // Tampilkan Loading Overlay
    if (!mounted) return;
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
        // Tampilkan Sukses Page
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => TransferSuccessPage(
                receiverId: receiverId,
                recipientName: _recipientName!,
                amount: amount,
              ),
            ),
          );
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

  @override
  Widget build(BuildContext context) {
    final txProvider = Provider.of<TransactionProvider>(context);
    final String balanceText =
        'IDR ${txProvider.octoPayBalance.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}';

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 72.0,
        title: const Text(
          'Transfer OCTO Pay',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Maroon Header Info
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF8B151A), Color(0xFF4A080A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Saldo OCTO Pay Anda',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
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
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
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
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade200, width: 1.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade200, width: 1.0),
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
                        inputFormatters: [ThousandsSeparatorInputFormatter()],
                        decoration: InputDecoration(
                          hintText: 'Masukkan nominal',
                          prefixIcon: const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF8B151A)),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade200, width: 1.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade200, width: 1.0),
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
                          final cleanValue = value.replaceAll(',', '').trim();
                          final amt = double.tryParse(cleanValue);
                          if (amt == null || amt < 10000) {
                            return 'Minimal transfer adalah IDR 10,000';
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
          color: const Color(0xFF8B151A).withValues(alpha: 0.06),
          border: Border.all(color: const Color(0xFF8B151A).withValues(alpha: 0.15)),
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

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  static const separator = ',';

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String textToFormat = newValue.text;
    int selectionIndex = newValue.selection.end;
    
    if (newValue.text.length == oldValue.text.length - 1 &&
        newValue.selection.end < oldValue.text.length &&
        newValue.selection.end >= 0 &&
        oldValue.text[newValue.selection.end] == separator) {
      int deletePos = newValue.selection.end - 1;
      if (deletePos >= 0) {
        textToFormat = newValue.text.substring(0, deletePos) + newValue.text.substring(deletePos + 1);
        selectionIndex = deletePos;
      }
    }

    String cleanText = textToFormat.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanText.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final buffer = StringBuffer();
    int digitsCount = cleanText.length;
    for (int i = 0; i < digitsCount; i++) {
      buffer.write(cleanText[i]);
      int remaining = digitsCount - 1 - i;
      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write(separator);
      }
    }

    final formattedText = buffer.toString();
    
    int digitsBeforeCursor = 0;
    for (int i = 0; i < selectionIndex; i++) {
      if (textToFormat[i] != separator && RegExp(r'[0-9]').hasMatch(textToFormat[i])) {
        digitsBeforeCursor++;
      }
    }
    
    int newSelectionIndex = 0;
    int digitsPlaced = 0;
    while (digitsPlaced < digitsBeforeCursor && newSelectionIndex < formattedText.length) {
      if (formattedText[newSelectionIndex] != separator) {
        digitsPlaced++;
      }
      newSelectionIndex++;
    }
    
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: newSelectionIndex),
    );
  }
}
