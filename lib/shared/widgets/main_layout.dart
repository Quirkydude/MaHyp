import 'package:flutter/material.dart';
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
        // TODO: Navigate to Home
        break;
      case 1:
        // TODO: Navigate to Health/BP Monitoring
        break;
      case 2:
        // TODO: Navigate to Medication
        break;
      case 3:
        // TODO: Navigate to Education
        break;
      case 4:
        // TODO: Navigate to More/Settings
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