import 'package:flutter/material.dart';
import 'dart:ui';
import '../screens/dashboard_screen.dart';
import '../screens/expense_list_screen.dart';
import '../screens/purchase_list_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/day_counter_screen.dart';
import '../screens/product_list_screen.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => BottomNavBarState();
}

class BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const ProductListScreen(),
    const ExpenseListScreen(),
    const PurchaseListScreen(),
    const DayCounterScreen(),
    const ProfileScreen(),
  ];

  final List<String> _titles = [
    'Dashboard',
    'Products',
    'Expenses',
    'Purchases',
    'Day Counter',
    'Profile',
  ];

  final List<IconData> _icons = [
    Icons.dashboard,
    Icons.inventory,
    Icons.receipt_long,
    Icons.shopping_cart,
    Icons.calculate,
    Icons.person,
  ];

  final Color selectedColor = const Color(0xFFFFA726); // Orange

  void _onDrawerItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.of(context).pop(); // Close the drawer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 1,
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
        title: null,
      ),
      drawer: Drawer(
        backgroundColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.center,
                    colors: [
                      Color(0xFF43e97b), // vibrant green
                      Color(0xFF232323), // dark
                    ],
                  ),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: Colors.white10, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha((0.25 * 255).toInt()),
                      blurRadius: 32,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    Center(child: Image.asset('assets/icon.png', height: 96)),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Divider(
                        color: Colors.white.withAlpha((0.12 * 255).toInt()),
                        thickness: 1.2,
                        height: 32,
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: _titles.length,
                        itemBuilder:
                            (context, i) => Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 2,
                              ),
                              child: ListTile(
                                leading: Icon(
                                  _icons[i],
                                  color:
                                      _selectedIndex == i
                                          ? selectedColor
                                          : Colors.white,
                                ),
                                title: Text(
                                  _titles[i],
                                  style: TextStyle(
                                    color:
                                        _selectedIndex == i
                                            ? selectedColor
                                            : Colors.white,
                                    fontWeight:
                                        _selectedIndex == i
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                    fontSize: 17,
                                  ),
                                ),
                                selected: _selectedIndex == i,
                                selectedTileColor: selectedColor.withAlpha(
                                  (0.08 * 255).toInt(),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                onTap: () => _onDrawerItemTapped(i),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 2,
                                ),
                                horizontalTitleGap: 12,
                                minLeadingWidth: 0,
                              ),
                            ),
                      ),
                    ),
                    // Add custom navigation for Raw Materials and Purchase Categories
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(
                              Icons.category,
                              color: Colors.white,
                            ),
                            title: const Text(
                              'Manage Raw Materials',
                              style: TextStyle(color: Colors.white),
                            ),
                            onTap: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pushNamed('/raw-materials');
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 2,
                            ),
                            horizontalTitleGap: 12,
                            minLeadingWidth: 0,
                          ),
                          ListTile(
                            leading: const Icon(
                              Icons.list_alt,
                              color: Colors.white,
                            ),
                            title: const Text(
                              'Manage Purchase Categories',
                              style: TextStyle(color: Colors.white),
                            ),
                            onTap: () {
                              Navigator.of(context).pop();
                              Navigator.of(
                                context,
                              ).pushNamed('/purchase-categories');
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 2,
                            ),
                            horizontalTitleGap: 12,
                            minLeadingWidth: 0,
                          ),
                          ListTile(
                            leading: const Icon(
                              Icons.store,
                              color: Colors.white,
                            ),
                            title: const Text(
                              'Manage Vendors',
                              style: TextStyle(color: Colors.white),
                            ),
                            onTap: () {
                              Navigator.of(context).pop();
                              Navigator.of(
                                context,
                              ).pushNamed('/vendor-management');
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 2,
                            ),
                            horizontalTitleGap: 12,
                            minLeadingWidth: 0,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0, top: 8.0),
                      child: ListTile(
                        leading: const Icon(Icons.logout, color: Colors.white),
                        title: const Text(
                          'Logout',
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: () async {
                          final nav = Navigator.of(context);
                          nav.pop(); // Close the drawer immediately
                          await Provider.of<AuthProvider>(
                            context,
                            listen: false,
                          ).logout();
                          nav.pushNamedAndRemoveUntil(
                            '/login',
                            (route) => false,
                          );
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 2,
                        ),
                        horizontalTitleGap: 12,
                        minLeadingWidth: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: _screens[_selectedIndex],
    );
  }
}
