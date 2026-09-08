import 'package:flutter/material.dart';

import '../../models/movie.dart';
import '../../services/movie_service.dart';
import 'movie_form_screen.dart';

class MoviesScreen extends StatelessWidget {
  const MoviesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Movie>>(
      stream: MovieService().getMovies(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final movies = snapshot.data ?? [];

        return Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    '${movies.length} Movies',
                    style: const TextStyle(color: Colors.white54),
                  ),

                  const Spacer(),

                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MovieFormScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Movie'),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              Expanded(
                child: ListView.separated(
                  itemCount: movies.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, index) {
                    return _movieCard(context, movies[index]);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _movieCard(BuildContext context, Movie movie) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111313),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            height: 90,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                movie.posterUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.movie),
              ),
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '${movie.genre} • ${movie.duration}',
                  style: const TextStyle(color: Colors.white54),
                ),

                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    movie.status,
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            tooltip: 'Edit',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MovieFormScreen(movie: movie),
                ),
              );
            },
            icon: const Icon(Icons.edit_outlined),
          ),

          IconButton(
            tooltip: 'Delete',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Delete movie?'),
                  content: Text('Delete ${movie.title}?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await MovieService().deleteMovie(movie.id);
              }
            },
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          ),
        ],
      ),
    );
  }
}
