import 'package:flutter/material.dart';

import '../../models/booking.dart';
import '../../services/booking_service.dart';

class BookingDetailsScreen extends StatelessWidget {
  final String bookingId;

  BookingDetailsScreen({super.key, required this.bookingId});

  final BookingService _bookingService = BookingService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Details')),
      body: StreamBuilder<Booking?>(
        stream: _bookingService.watchBooking(bookingId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load booking.\n\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final booking = snapshot.data;

          if (booking == null) {
            return const Center(child: Text('Booking not found.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _codeCard(context, booking),

                const SizedBox(height: 20),

                _section('Customer', [
                  _row('Name', booking.customerName),
                  _row('Phone', booking.customerPhone),
                ]),

                const SizedBox(height: 16),

                _section('Movie', [_row('Movie', booking.movieTitle)]),

                const SizedBox(height: 16),

                _section('Showtime', [
                  _row('Hall', booking.hallName),
                  _row('Date', _formatDate(booking.date)),
                  _row('Time', booking.startTime),
                ]),

                const SizedBox(height: 16),

                _section('Seats', [
                  _row('Seats', booking.seats.join(', ')),
                  _row('Seat count', '${booking.seatCount}'),
                  _row(
                    'Price / seat',
                    '\$${booking.pricePerSeat.toStringAsFixed(2)}',
                  ),
                  _row('Total', '\$${booking.total.toStringAsFixed(2)}'),
                ]),

                const SizedBox(height: 16),

                _section('Status', [
                  _row('Status', booking.status.toUpperCase()),
                ]),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _codeCard(BuildContext context, Booking booking) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            'BOOKING CODE',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          SelectableText(
            booking.bookingCode,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(title, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
