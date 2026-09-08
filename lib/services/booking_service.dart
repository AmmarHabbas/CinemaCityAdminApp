import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/booking.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================================
  // REAL-TIME BOOKINGS
  // ============================================================

  Stream<List<Booking>> getBookings() {
    return _firestore
        .collection('bookings')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Booking.fromFirestore(doc))
              .toList();
        });
  }

  // ============================================================
  // SINGLE BOOKING
  // ============================================================

  Stream<Booking?> watchBooking(String bookingId) {
    return _firestore.collection('bookings').doc(bookingId).snapshots().map((
      doc,
    ) {
      if (!doc.exists) {
        return null;
      }

      return Booking.fromFirestore(doc);
    });
  }
}
