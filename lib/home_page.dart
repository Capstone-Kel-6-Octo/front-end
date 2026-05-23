import 'package:flutter/material.dart';
import 'widgets/custom_bottom_nav.dart';
import 'widgets/header1.dart';
// import 'widgets/header2.dart';
// import 'widgets/header3.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
      floatingActionButton: const QrisFloatingButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // Uncomment salah satu baris di bawah ini untuk mengganti tampilan header
      body: const Header1(),
      // body: const Header2(),
      // body: const Header3(),
    );
  }
}
