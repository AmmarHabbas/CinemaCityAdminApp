import 'package:cinema_admin/screens/halls/halls_screen.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';

import '../screens/dashboard/dashboard_screen.dart';
import '../screens/movies/movies_screen.dart';
import '../screens/showtimes/showtimes_screen.dart';
import '../screens/bookings/bookings_screen.dart';
import '../screens/customers/customers_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int selectedIndex = 0;

  final pages = [
    DashboardScreen(),
    MoviesScreen(),
    HallsScreen(),
    ShowtimesScreen(),
    BookingsScreen(),
    CustomersScreen(),
  ];

  final titles = const [
    'Dashboard',
    'Movies',
    'Halls',
    'Showtimes',
    'Bookings',
    'Customers',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 245,
            color: const Color(0xFF0D0F0F),
            child: Column(
              children: [
                const SizedBox(height: 35),

                const Icon(
                  Icons.movie_filter_rounded,
                  size: 45,
                  color: Color(0xFFF3F0D6),
                ),

                const SizedBox(height: 12),

                const Text(
                  'CINEMA',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                  ),
                ),

                const Text(
                  'ADMIN',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    letterSpacing: 3,
                  ),
                ),

                const SizedBox(height: 40),

                Expanded(
                  child: ListView(
                    children: [
                      _navItem(0, Icons.dashboard_outlined, 'Dashboard'),
                      _navItem(1, Icons.movie_outlined, 'Movies'),
                      _navItem(2, Icons.meeting_room_outlined, 'Halls'),
                      _navItem(3, Icons.schedule_outlined, 'Showtimes'),

                      _navItem(
                        4,
                        Icons.confirmation_number_outlined,
                        'Bookings',
                      ),
                      _navItem(5, Icons.people_outline, 'Customers'),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(15),
                  child: ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Sign Out'),
                    onTap: () {
                      AuthService().signOut();
                    },
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Column(
              children: [
                Container(
                  height: 75,
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.white10)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        titles[selectedIndex],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Spacer(),
                      const CircleAvatar(child: Icon(Icons.person)),
                    ],
                  ),
                ),

                Expanded(child: pages[selectedIndex]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String title) {
    final selected = selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: ListTile(
        selected: selected,
        selectedTileColor: const Color(0xFFF3F0D6),
        selectedColor: Colors.yellowAccent,
        leading: Icon(icon),
        title: Text(title),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {
          setState(() {
            selectedIndex = index;
          });
        },
      ),
    );
  }
}
