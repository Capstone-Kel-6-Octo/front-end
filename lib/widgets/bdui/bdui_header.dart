import 'package:flutter/material.dart';
import '../../services/session_manager.dart';
import '../custom_top_nav.dart';

class BduiHeader extends StatelessWidget {
  final String persona;

  const BduiHeader({
    super.key,
    required this.persona,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Establish premium brand styling based on user persona
    List<Color> gradientColors;
    String greetingPrefix;
    Widget? badge;

    switch (persona.toUpperCase()) {
      case 'PRIORITAS':
        gradientColors = [const Color(0xFF1F1F1F), const Color(0xFF3D321F)]; // Black & Gold
        greetingPrefix = 'Selamat siang Anggota Prioritas, ';
        badge = Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFD4AF37), // Metallic Gold
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'PRIORITAS',
            style: TextStyle(
              color: Colors.black,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
        );
        break;
      case 'PENGUSAHA':
      case 'BISNIS':
        gradientColors = [const Color(0xFF0A2540), const Color(0xFF001020)]; // Deep Corporate Blue
        greetingPrefix = 'Selamat siang Rekan Bisnis, ';
        badge = Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF00D4B2), // Emerald Teal
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'PENGUSAHA',
            style: TextStyle(
              color: Colors.black,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
        );
        break;
      case 'REGULER':
      default:
        gradientColors = [const Color(0xFF8B151A), const Color(0xFF6B0B0C)]; // Brand Maroon
        greetingPrefix = 'Selamat siang, ';
        break;
    }

    final String userName = SessionManager.currentUser?.name.toUpperCase() ?? 'NAYLA LARAS DAMAYANTI';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Standard Custom Top Nav
            const CustomTopNav(),

            // Greeting Segment
            Padding(
              padding: const EdgeInsets.only(top: 12, left: 24, right: 24, bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text.rich(
                        TextSpan(
                          text: greetingPrefix,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.normal,
                          ),
                          children: [
                            TextSpan(
                              text: '$userName !',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (badge != null) ...[badge],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
