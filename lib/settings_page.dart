import 'package:flutter/material.dart';
import 'widgets/custom_bottom_nav.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Settings Page'),
      ),
      bottomNavigationBar: CustomBottomNav(currentIndex: 3),
      floatingActionButton: QrisFloatingButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
