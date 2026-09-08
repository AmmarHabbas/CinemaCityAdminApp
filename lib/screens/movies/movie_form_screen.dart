import 'package:flutter/material.dart';

import '../../models/cast_member.dart';
import '../../models/movie.dart';
import '../../services/movie_service.dart';

class MovieFormScreen extends StatefulWidget {
  final Movie? movie;

  const MovieFormScreen({super.key, this.movie});

  @override
  State<MovieFormScreen> createState() => _MovieFormScreenState();
}

class _MovieFormScreenState extends State<MovieFormScreen> {
  final titleController = TextEditingController();
  final posterController = TextEditingController();
  final trailerController = TextEditingController();
  final genreController = TextEditingController();
  final durationController = TextEditingController();
  final ratingController = TextEditingController();
  final descriptionController = TextEditingController();

  String status = 'nowPlaying';
  DateTime? releaseDate;

  final List<CastMember> cast = [];

  @override
  void initState() {
    super.initState();

    final movie = widget.movie;

    if (movie != null) {
      titleController.text = movie.title;
      posterController.text = movie.posterUrl;
      trailerController.text = movie.trailerUrl;
      genreController.text = movie.genre;
      durationController.text = movie.duration;
      ratingController.text = movie.rating.toString();
      descriptionController.text = movie.description;
      status = movie.status;
      releaseDate = movie.releaseDate;
      cast.addAll(movie.cast);
    }
  }

  Future<void> save() async {
    final movie = Movie(
      id: widget.movie?.id ?? '',
      title: titleController.text.trim(),
      posterUrl: posterController.text.trim(),
      trailerUrl: trailerController.text.trim(),
      genre: genreController.text.trim(),
      duration: durationController.text.trim(),
      rating: double.tryParse(ratingController.text) ?? 0,
      description: descriptionController.text.trim(),
      status: status,
      releaseDate: releaseDate,
      cast: List.from(cast),
    );

    if (widget.movie == null) {
      await MovieService().addMovie(movie);
    } else {
      await MovieService().updateMovie(movie);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.movie != null;

    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Edit Movie' : 'Add Movie')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              children: [
                _field(titleController, 'Movie Title'),

                _field(posterController, 'Poster URL'),

                _field(trailerController, 'Trailer URL'),

                Row(
                  children: [
                    Expanded(child: _field(genreController, 'Genre')),
                    const SizedBox(width: 15),
                    Expanded(child: _field(durationController, 'Duration')),
                    const SizedBox(width: 15),
                    Expanded(child: _field(ratingController, 'Rating')),
                  ],
                ),

                _field(descriptionController, 'Description', maxLines: 5),

                const SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  value: status,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'nowPlaying',
                      child: Text('Now Playing'),
                    ),
                    DropdownMenuItem(
                      value: 'comingSoon',
                      child: Text('Coming Soon'),
                    ),
                    DropdownMenuItem(
                      value: 'tomorrow',
                      child: Text('Tomorrow'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        status = value;
                      });
                    }
                  },
                ),

                const SizedBox(height: 15),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _chooseDate,
                        icon: const Icon(Icons.calendar_month),
                        label: Text(
                          releaseDate == null
                              ? 'Choose Release Date'
                              : '${releaseDate!.day}/${releaseDate!.month}/${releaseDate!.year}',
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                _castSection(),

                const SizedBox(height: 35),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: save,
                    child: Text(editing ? 'SAVE CHANGES' : 'ADD MOVIE'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Future<void> _chooseDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: releaseDate ?? DateTime.now(),
    );

    if (date != null) {
      setState(() {
        releaseDate = date;
      });
    }
  }

  Widget _castSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Cast',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: _addCast,
              icon: const Icon(Icons.add),
              label: const Text('Add Cast'),
            ),
          ],
        ),

        const SizedBox(height: 15),

        ...cast.asMap().entries.map((entry) {
          final index = entry.key;
          final actor = entry.value;

          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: actor.photoUrl.isNotEmpty
                    ? NetworkImage(actor.photoUrl)
                    : null,
                child: actor.photoUrl.isEmpty ? const Icon(Icons.person) : null,
              ),
              title: Text(actor.name),
              subtitle: Text(actor.role),
              trailing: IconButton(
                onPressed: () {
                  setState(() {
                    cast.removeAt(index);
                  });
                },
                icon: const Icon(Icons.delete, color: Colors.redAccent),
              ),
            ),
          );
        }),
      ],
    );
  }

  Future<void> _addCast() async {
    final name = TextEditingController();
    final role = TextEditingController();
    final photo = TextEditingController();

    final result = await showDialog<CastMember>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Cast Member'),
        content: SizedBox(
          width: 450,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogField(name, 'Actor Name'),
              _dialogField(role, 'Character / Role'),
              _dialogField(photo, 'Photo URL'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(
                context,
                CastMember(
                  name: name.text.trim(),
                  role: role.text.trim(),
                  photoUrl: photo.text.trim(),
                ),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    name.dispose();
    role.dispose();
    photo.dispose();

    if (result != null) {
      setState(() {
        cast.add(result);
      });
    }
  }

  Widget _dialogField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    posterController.dispose();
    trailerController.dispose();
    genreController.dispose();
    durationController.dispose();
    ratingController.dispose();
    descriptionController.dispose();

    super.dispose();
  }
}
