import 'package:flutter/material.dart';
import 'widgets/custom_bottom_nav.dart';

class MyAccountPage extends StatelessWidget {
  const MyAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('My Account Page'),
      ),
      bottomNavigationBar: CustomBottomNav(currentIndex: 1),
      floatingActionButton: QrisFloatingButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
