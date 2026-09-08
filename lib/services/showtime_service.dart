import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/showtime.dart';

class ShowtimeService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // ============================================================
  // GET ALL SHOWTIMES
  // ============================================================

  Stream<List<Showtime>> getShowtimes() {
    return firestore.collection('showtimes').orderBy('date').snapshots().map((
      snapshot,
    ) {
      final showtimes = snapshot.docs
          .map((doc) => Showtime.fromFirestore(doc))
          .toList();

      // Sort by date + time.
      showtimes.sort((a, b) {
        final aDateTime = _combineDateAndTime(a.date, a.startTime);

        final bDateTime = _combineDateAndTime(b.date, b.startTime);

        return aDateTime.compareTo(bDateTime);
      });

      return showtimes;
    });
  }

  // ============================================================
  // ADD SHOWTIME
  // ============================================================

  Future<void> addShowtime(Showtime showtime) async {
    await firestore.collection('showtimes').add(showtime.toMap());
  }

  // ============================================================
  // UPDATE SHOWTIME
  // ============================================================

  Future<void> updateShowtime(Showtime showtime) async {
    await firestore
        .collection('showtimes')
        .doc(showtime.id)
        .update(showtime.toMap());
  }

  // ============================================================
  // DELETE SHOWTIME
  // ============================================================

  Future<void> deleteShowtime(String id) async {
    await firestore.collection('showtimes').doc(id).delete();
  }

  // ============================================================
  // COMBINE DATE + TIME
  // ============================================================

  DateTime _combineDateAndTime(DateTime date, String time) {
    final parts = time.split(':');

    final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;

    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

    return DateTime(date.year, date.month, date.day, hour, minute);
  }
}
