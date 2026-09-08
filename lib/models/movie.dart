import 'package:cloud_firestore/cloud_firestore.dart';

import 'cast_member.dart';

class Movie {
  final String id;
  final String title;
  final String posterUrl;
  final String trailerUrl;
  final String genre;
  final String duration;
  final double rating;
  final String description;
  final String status;
  final DateTime? releaseDate;
  final List<CastMember> cast;

  const Movie({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.trailerUrl,
    required this.genre,
    required this.duration,
    required this.rating,
    required this.description,
    required this.status,
    this.releaseDate,
    this.cast = const [],
  });

  factory Movie.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    final castData = data['cast'] as List? ?? [];

    return Movie(
      id: doc.id,
      title: data['title'] ?? '',
      posterUrl: data['posterUrl'] ?? '',
      trailerUrl: data['trailerUrl'] ?? '',
      genre: data['genre'] ?? '',
      duration: data['duration'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      description: data['description'] ?? '',
      status: data['status'] ?? '',
      releaseDate: (data['releaseDate'] as Timestamp?)?.toDate(),
      cast: castData
          .map((e) => CastMember.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'posterUrl': posterUrl,
      'trailerUrl': trailerUrl,
      'genre': genre,
      'duration': duration,
      'rating': rating,
      'description': description,
      'status': status,
      'releaseDate': releaseDate == null
          ? null
          : Timestamp.fromDate(releaseDate!),
      'cast': cast.map((e) => e.toMap()).toList(),
    };
  }
}
