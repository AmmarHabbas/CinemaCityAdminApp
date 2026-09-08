import 'package:cloud_firestore/cloud_firestore.dart';

class Customer {
  final String id;
  final String name;
  final String phoneNumber;
  final String? email;
  final DateTime? createdAt;

  // Keeps any additional fields that may exist
  // inside the customer's Firestore document.
  final Map<String, dynamic> data;

  Customer({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.email,
    this.createdAt,
    required this.data,
  });

  factory Customer.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    DateTime? createdAt;

    final createdAtValue = data['createdAt'];

    if (createdAtValue is Timestamp) {
      createdAt = createdAtValue.toDate();
    }

    return Customer(
      id: doc.id,
      name: data['name']?.toString() ?? '',
      phoneNumber: data['phoneNumber']?.toString() ?? '',
      email: data['email']?.toString(),
      createdAt: createdAt,
      data: Map<String, dynamic>.from(data),
    );
  }
}
