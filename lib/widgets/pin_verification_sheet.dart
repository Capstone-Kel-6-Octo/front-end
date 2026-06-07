import 'package:flutter/material.dart';

class PinVerificationSheet extends StatefulWidget {
  const PinVerificationSheet({super.key});

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PinVerificationSheet(),
    );
  }

  @override
  State<PinVerificationSheet> createState() => _PinVerificationSheetState();
}

class _PinVerificationSheetState extends State<PinVerificationSheet> {
  String _enteredPin = '';
  String? _errorMessage;

  void _handleKeyPress(String val) {
    setState(() {
      _errorMessage = null; // Clear error on new press
      if (_enteredPin.length < 6) {
        _enteredPin += val;
      }
    });

    if (_enteredPin.length == 6) {
      // Verify PIN
      if (_enteredPin == '123456') {
        Navigator.pop(context, true);
      } else {
        setState(() {
          _errorMessage = 'PIN salah. Silakan coba lagi ';
          _enteredPin = ''; // Reset pin input
        });
      }
    }
  }

  void _handleBackspace() {
    setState(() {
      _errorMessage = null;
      if (_enteredPin.isNotEmpty) {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          
          // Icon Lock
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF8B151A).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              color: Color(0xFF8B151A),
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          
          const Text(
            'Masukkan PIN Transaksi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          
          Text(
            'Silakan masukkan 6 digit PIN untuk memverifikasi transaksi.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 6),
          
          const Text(
            '(PIN Default: 123456)',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8B151A),
            ),
          ),
          const SizedBox(height: 24),
          
          // PIN Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (index) {
              bool isFilled = index < _enteredPin.length;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: isFilled ? const Color(0xFF8B151A) : Colors.grey.shade200,
                  shape: BoxShape.circle,
                  border: isFilled
                      ? null
                      : Border.all(color: Colors.grey.shade300, width: 1.5),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          
          // Error Message
          if (_errorMessage != null)
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          const SizedBox(height: 28),
          
          // Custom Keypad
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ['1', '2', '3'].map((val) => _buildNumpadButton(val)).toList(),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ['4', '5', '6'].map((val) => _buildNumpadButton(val)).toList(),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ['7', '8', '9'].map((val) => _buildNumpadButton(val)).toList(),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Cancel button
                  SizedBox(
                    width: 68,
                    height: 68,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context, false),
                      icon: const Icon(Icons.close_rounded, color: Colors.grey),
                    ),
                  ),
                  _buildNumpadButton('0'),
                  // Backspace button
                  SizedBox(
                    width: 68,
                    height: 68,
                    child: IconButton(
                      onPressed: _handleBackspace,
                      icon: const Icon(Icons.backspace_outlined, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildNumpadButton(String label) {
    return GestureDetector(
      onTap: () => _handleKeyPress(label),
      child: Container(
        width: 68,
        height: 68,
        decoration: const BoxDecoration(
          color: Color(0xFFF1F5F9), // Premium Slate Grey background for grid buttons
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
