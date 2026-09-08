import 'package:cloud_firestore/cloud_firestore.dart';

class HallSeat {
  final String id;
  final String row;
  final int number;

  HallSeat({required this.id, required this.row, required this.number});

  Map<String, dynamic> toMap() {
    return {'id': id, 'row': row, 'number': number};
  }

  factory HallSeat.fromMap(Map<String, dynamic> map) {
    return HallSeat(
      id: map['id'] ?? '',
      row: map['row'] ?? '',
      number: map['number'] ?? 0,
    );
  }
}

class Hall {
  final String id;
  final String name;
  final int rows;
  final int seatsPerRow;
  final List<HallSeat> seats;
  final DateTime? createdAt;

  Hall({
    required this.id,
    required this.name,
    required this.rows,
    required this.seatsPerRow,
    required this.seats,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'rows': rows,
      'seatsPerRow': seatsPerRow,
      'seats': seats.map((seat) => seat.toMap()).toList(),
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  factory Hall.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    final seatsData = data['seats'] as List<dynamic>? ?? [];

    return Hall(
      id: doc.id,
      name: data['name'] ?? '',
      rows: (data['rows'] ?? 0) as int,
      seatsPerRow: (data['seatsPerRow'] ?? 0) as int,
      seats: seatsData
          .map(
            (seat) => HallSeat.fromMap(Map<String, dynamic>.from(seat as Map)),
          )
          .toList(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
