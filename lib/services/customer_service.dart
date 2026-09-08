import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/customer.dart';

class CustomerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================================
  // GET ALL CUSTOMERS
  // ============================================================

  Stream<List<Customer>> getCustomers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      final customers = snapshot.docs
          .map((doc) => Customer.fromFirestore(doc))
          .toList();

      // Sort locally by customer name.
      // This avoids requiring a Firestore index.
      customers.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );

      return customers;
    });
  }

  // ============================================================
  // GET ONE CUSTOMER
  // ============================================================

  Future<Customer?> getCustomer(String customerId) async {
    final doc = await _firestore.collection('users').doc(customerId).get();

    if (!doc.exists) {
      return null;
    }

    return Customer.fromFirestore(doc);
  }

  // ============================================================
  // UPDATE CUSTOMER
  // ============================================================

  Future<void> updateCustomer({
    required String customerId,
    required String name,
    required String phoneNumber,
  }) async {
    await _firestore.collection('users').doc(customerId).update({
      'name': name.trim(),
      'phoneNumber': phoneNumber.trim(),
    });
  }

  // ============================================================
  // DELETE CUSTOMER
  // ============================================================

  Future<void> deleteCustomer(String customerId) async {
    await _firestore.collection('users').doc(customerId).delete();
  }
}
