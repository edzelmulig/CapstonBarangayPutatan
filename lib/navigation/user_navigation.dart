import 'dart:async';
import 'package:flutter/material.dart';
import 'package:putatanapk/navigation/navigationbar_components.dart';
import 'package:putatanapk/services/firebase_services.dart';
import 'package:putatanapk/ui/screens/client/client_emergency.dart';
import 'package:putatanapk/ui/screens/client/client_homescreen.dart';
import 'package:putatanapk/ui/screens/client/client_profile.dart';
import 'package:putatanapk/ui/screens/client/client_transactions.dart';
import 'package:putatanapk/ui/widgets/snackbar/custom_snackbar.dart';

class UserNavigation extends StatefulWidget {
  const UserNavigation({super.key});

  @override
  State<UserNavigation> createState() => _UserNavigationState();
}

class _UserNavigationState extends State<UserNavigation> {
  // Navigation index
  static const int _defaultIndex = 0;
  int _selectedIndex = _defaultIndex;
  bool _hasNewUpdateNotification = false;

  // List of pages
  final List<Widget> _pages = [
    const ClientHomescreen(),
    const ClientTransactions(),
    const ClientEmergency(),
    const ClientProfile(),
  ];

  // Navigate to bottom bar item
  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 3) {
        _hasNewUpdateNotification = false;
      }
    });
  }

  // LISTEN TO THE CHANGES IN THE NOTIFICATION

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFFEFFFE),
        unselectedFontSize: 11,
        selectedFontSize: 11,
        selectedItemColor: const Color(0xFF3C3C40),
        currentIndex: _selectedIndex,
        onTap: _navigateBottomBar,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
        ),
        items: [
          NavigationUtils.buildBottomNavigationBarItem(
            selectedIcon: Icons.home_rounded,
            unselectedIcon: Icons.home_outlined,
            label: "Home",
            index: 0,
            selectedIndex: _selectedIndex,
            isClient: true,
          ),
          NavigationUtils.buildBottomNavigationBarItem(
            selectedIcon: Icons.receipt_rounded,
            unselectedIcon: Icons.receipt_outlined,
            label: "Transactions",
            index: 1,
            selectedIndex: _selectedIndex,
            hasNewUpdateNotification: _hasNewUpdateNotification,
            isClient: true,
          ),
          NavigationUtils.buildBottomNavigationBarItem(
            selectedIcon: Icons.call_end,
            unselectedIcon: Icons.call_end_outlined,
            label: "Emergency",
            index: 2,
            selectedIndex: _selectedIndex,
            hasNewUpdateNotification: _hasNewUpdateNotification,
            isClient: true,
          ),
          NavigationUtils.buildBottomNavigationBarItem(
            selectedIcon: Icons.person,
            unselectedIcon: Icons.person_outline,
            label: "Profile",
            index: 3,
            selectedIndex: _selectedIndex,
            hasNewUpdateNotification: _hasNewUpdateNotification,
            isClient: true,
          ),
        ],
      ),
    );
  }
}
