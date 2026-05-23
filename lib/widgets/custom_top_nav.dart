import 'package:flutter/material.dart';
import '../login_page.dart';
import '../services/session_manager.dart';

class CustomTopNav extends StatelessWidget {
  const CustomTopNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 10,
        bottom: 16,
        left: 18,
        right: 18,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/navbar/OCTO 1.png',
            height: 22,
            fit: BoxFit.contain,
          ),
          Row(
            children: [
              Image.asset('assets/navbar/heart.png', height: 24, width: 24),
              const SizedBox(width: 14),
              Image.asset('assets/navbar/search.png', height: 24, width: 24),
              const SizedBox(width: 14),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Image.asset('assets/navbar/notif.png', height: 24, width: 24),
                  Positioned(
                    top: -2,
                    right: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF5252),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF7D1115),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              GestureDetector(
                onTap: () {
                  SessionManager.clearSession();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                child: Image.asset('assets/navbar/logout.png', height: 24, width: 24),
              ),
              const SizedBox(width: 14),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2.0,
                  ),
                ),
                child: const CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage('assets/navbar/OCTO_Mascot 1.png'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
