import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/hall.dart';

class HallService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // ============================================================
  // GET ALL HALLS
  // ============================================================

  Stream<List<Hall>> getHalls() {
    return firestore.collection('halls').orderBy('name').snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) => Hall.fromFirestore(doc)).toList();
    });
  }

  // ============================================================
  // ADD HALL
  // ============================================================

  Future<String> addHall(Hall hall) async {
    final docRef = await firestore.collection('halls').add(hall.toMap());

    return docRef.id;
  }

  // ============================================================
  // UPDATE HALL
  // ============================================================

  Future<void> updateHall(Hall hall) async {
    if (hall.id.isEmpty) {
      throw Exception('Cannot update hall without an ID.');
    }

    await firestore.collection('halls').doc(hall.id).update(hall.toMap());
  }

  // ============================================================
  // DELETE HALL
  // ============================================================

  Future<void> deleteHall(String hallId) async {
    if (hallId.isEmpty) {
      throw Exception('Cannot delete hall without an ID.');
    }

    await firestore.collection('halls').doc(hallId).delete();
  }
}
