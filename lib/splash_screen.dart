import 'package:flutter/material.dart';
import 'package:octo/login_page.dart'; // import the login page to navigate to

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  _navigateToLogin() async {
    await Future.delayed(const Duration(seconds: 3), () {});
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            'assets/bg_Log.png',
            fit: BoxFit.cover,
          ),
          // Logo in the center
          Center(
            child: Image.asset(
              'assets/OCTO_by_CIMB_Niaga 1 1.png',
              width: 200, // Adjust width as necessary
            ),
          ),
          // Text at the bottom
          const Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hak Cipta, 2011. PT Bank CIMB Niaga Tbk berizin & diawasi\n'
                  'oleh Otoritas Jasa Keuangan & Bank Indonesia serta\n'
                  'merupakan Peserta Penjamin LPS',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10, // Adjust font size as matching
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Version 3.1.85',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
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
