import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:putatanapk/navigation/navigationbar_components.dart';
import 'package:putatanapk/ui/screens/admin/admin_homescreen.dart';
import 'package:putatanapk/ui/screens/admin/admin_profile.dart';
import 'package:putatanapk/ui/screens/admin/admin_transactions.dart';
import 'package:putatanapk/ui/screens/admin/my_transactions/view_all_transactions.dart';

class AdminNavigation extends StatefulWidget {
  const AdminNavigation({super.key});

  @override
  State<AdminNavigation> createState() => _AdminNavigationState();
}

class _AdminNavigationState extends State<AdminNavigation> {
  // Navigation index
  static const int _defaultIndex = 0;
  int _selectedIndex = _defaultIndex;
  bool _hasNewUpdateNotification = false;

  // Stream subscription
  late StreamSubscription<QuerySnapshot>? _notificationSubscription;

  // List of pages
  final List<Widget> _pages = [
    const AdminHomescreen(),
    const ViewAllTransactions(),
    const AdminProfile(),
  ];



  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  // Navigate to bottom bar item
  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 2) {
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
            isClient: false,
          ),
          NavigationUtils.buildBottomNavigationBarItem(
            selectedIcon: Icons.receipt_rounded,
            unselectedIcon: Icons.receipt_outlined,
            label: "Transactions",
            index: 1,
            selectedIndex: _selectedIndex,
            hasNewUpdateNotification: _hasNewUpdateNotification,
            isClient: false,
          ),
          NavigationUtils.buildBottomNavigationBarItem(
            selectedIcon: Icons.person,
            unselectedIcon: Icons.person_outline,
            label: "Account",
            index: 2,
            selectedIndex: _selectedIndex,
            hasNewUpdateNotification: _hasNewUpdateNotification,
            isClient: false,
          ),
        ],
      ),
    );
  }
}