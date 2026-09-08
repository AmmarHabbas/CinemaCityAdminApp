import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../widgets/stat_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('movies').snapshots(),
      builder: (context, movieSnapshot) {
        final movieCount = movieSnapshot.data?.docs.length ?? 0;

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
          builder: (context, bookingSnapshot) {
            final bookingCount = bookingSnapshot.data?.docs.length ?? 0;

            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .snapshots(),
              builder: (context, userSnapshot) {
                final customerCount = userSnapshot.data?.docs.length ?? 0;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome back 👋',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Here is what is happening in your cinema.',
                        style: TextStyle(color: Colors.white54),
                      ),

                      const SizedBox(height: 30),

                      GridView.count(
                        crossAxisCount: 4,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        childAspectRatio: 1.7,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          StatCard(
                            title: 'Total Movies',
                            value: '$movieCount',
                            icon: Icons.movie_outlined,
                          ),

                          StatCard(
                            title: 'Bookings',
                            value: '$bookingCount',
                            icon: Icons.confirmation_number_outlined,
                          ),

                          StatCard(
                            title: 'Customers',
                            value: '$customerCount',
                            icon: Icons.people_outline,
                          ),

                          const StatCard(
                            title: 'Revenue',
                            value: '€0',
                            icon: Icons.euro_outlined,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
