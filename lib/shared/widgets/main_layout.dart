import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'bottom_nav_bar.dart';

/// Main layout wrapper with bottom navigation
/// Use this for all main app screens (Home, Health, Medication, etc.)
class MainLayout extends StatefulWidget {
  final int currentIndex;
  final Widget child;

  const MainLayout({
    super.key,
    required this.currentIndex,
    required this.child,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  void _onNavBarTap(int index) {
    // Navigation logic based on index
    switch (index) {
      case 0:
        context.go('/bp-history'); // TODO: Change to home Joel Pushes ready
        break;
      case 1:
        context.go('/bp-history');
        break;
      case 2:
        context.go('/medication-list');
        break;
      case 3:
        context.go('/education');
        break;
      case 4:
        context.go('/support');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavBar(
        currentIndex: widget.currentIndex,
        onTap: _onNavBarTap,
      ),
    );
  }
}
