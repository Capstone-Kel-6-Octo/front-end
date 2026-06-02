import 'package:flutter/material.dart';
import 'widgets/custom_bottom_nav.dart';

class WealthPage extends StatelessWidget {
  const WealthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Wealth Page'),
      ),
      bottomNavigationBar: CustomBottomNav(currentIndex: 2),
      floatingActionButton: SizedBox(width: 68, height: 68),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
