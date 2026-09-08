import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/movie.dart';

class MovieService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Stream<List<Movie>> getMovies() {
    return firestore
        .collection('movies')
        .orderBy('releaseDate')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Movie.fromFirestore(doc)).toList(),
        );
  }

  Future<void> addMovie(Movie movie) async {
    await firestore.collection('movies').add(movie.toMap());
  }

  Future<void> updateMovie(Movie movie) async {
    await firestore.collection('movies').doc(movie.id).update(movie.toMap());
  }

  Future<void> deleteMovie(String id) async {
    await firestore.collection('movies').doc(id).delete();
  }
}
