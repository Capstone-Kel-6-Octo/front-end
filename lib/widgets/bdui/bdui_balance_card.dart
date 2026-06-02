import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';

class BduiBalanceCard extends StatefulWidget {
  final String persona;

  const BduiBalanceCard({
    super.key,
    required this.persona,
  });

  @override
  State<BduiBalanceCard> createState() => _BduiBalanceCardState();
}

class _BduiBalanceCardState extends State<BduiBalanceCard> {
  bool _isBalanceVisible = false;

  @override
  Widget build(BuildContext context) {
    // Styling and value adaptations by user persona
    Color tagColor;
    String tagLabel;
    Color actionIconBg;
    String balanceText;

    final txProvider = Provider.of<TransactionProvider>(context);
    final double balance = txProvider.octoPayBalance;
    final String dynamicBalanceText = 'IDR ${balance.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}';

    switch (widget.persona.toUpperCase()) {
      case 'PRIORITAS':
        tagColor = const Color(0xFF3D321F); // Dark gold
        tagLabel = 'Priority Asset';
        actionIconBg = const Color(0xFF3D321F);
        balanceText = dynamicBalanceText;
        break;
      case 'PENGUSAHA':
      case 'BISNIS':
        tagColor = const Color(0xFF0A2540); // Deep business blue
        tagLabel = 'Business Account';
        actionIconBg = const Color(0xFF0A2540);
        balanceText = dynamicBalanceText;
        break;
      case 'REGULER':
      default:
        tagColor = const Color(0xFF13504A); // Original dark green
        tagLabel = 'E-Wallet';
        actionIconBg = const Color(0xFF8B151A); // Brand maroon
        balanceText = dynamicBalanceText;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: tagColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tagLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text(
                    'OCTO Pay',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(••••8481)',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(const ClipboardData(text: '123456788481'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Nomor Rekening berhasil disalin'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Icon(
                      Icons.copy,
                      size: 14,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isBalanceVisible = !_isBalanceVisible;
                      });
                    },
                    child: Icon(
                      _isBalanceVisible ? Icons.visibility : Icons.visibility_outlined,
                      size: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isBalanceVisible ? balanceText : 'IDR •••',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: actionIconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Isi Ulang',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
