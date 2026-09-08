import 'package:flutter/material.dart';

import '../../models/booking.dart';
import '../../services/booking_service.dart';

import 'booking_details_screen.dart';

class BookingsScreen extends StatelessWidget {
  BookingsScreen({super.key});

  final BookingService _bookingService = BookingService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bookings')),
      body: StreamBuilder<List<Booking>>(
        stream: _bookingService.getBookings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Failed to load bookings.\n\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final bookings = snapshot.data ?? [];

          if (bookings.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.confirmation_number_outlined, size: 60),
                  SizedBox(height: 16),
                  Text(
                    'No bookings yet',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];

              return _bookingCard(context, booking);
            },
          );
        },
      ),
    );
  }

  Widget _bookingCard(BuildContext context, Booking booking) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BookingDetailsScreen(bookingId: booking.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.confirmation_number_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.bookingCode,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      booking.movieTitle,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      '${booking.hallName} • ${booking.startTime}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${booking.total.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    '${booking.seatCount} seat(s)',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                  ),
                ],
              ),

              const SizedBox(width: 8),

              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
