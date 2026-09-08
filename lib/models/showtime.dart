import 'package:cloud_firestore/cloud_firestore.dart';

class Showtime {
  final String id;

  final String movieId;
  final String movieTitle;

  final String hallId;
  final String hallName;

  final DateTime date;
  final String startTime;

  final double price;

  final DateTime? createdAt;

  Showtime({
    required this.id,
    required this.movieId,
    required this.movieTitle,
    required this.hallId,
    required this.hallName,
    required this.date,
    required this.startTime,
    required this.price,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'movieId': movieId,
      'movieTitle': movieTitle,
      'hallId': hallId,
      'hallName': hallName,
      'date': Timestamp.fromDate(date),
      'startTime': startTime,
      'price': price,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  factory Showtime.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    DateTime parsedDate = DateTime.now();

    final dateValue = data['date'];

    if (dateValue is Timestamp) {
      parsedDate = dateValue.toDate();
    }

    return Showtime(
      id: doc.id,
      movieId: data['movieId'] ?? '',
      movieTitle: data['movieTitle'] ?? '',
      hallId: data['hallId'] ?? '',
      hallName: data['hallName'] ?? '',
      date: parsedDate,
      startTime: data['startTime'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
