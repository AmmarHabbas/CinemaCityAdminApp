import 'package:flutter/material.dart';

import '../../models/movie.dart';
import '../../models/hall.dart';
import '../../models/showtime.dart';

import '../../services/movie_service.dart';
import '../../services/hall_service.dart';
import '../../services/showtime_service.dart';

class AddEditShowtimeScreen extends StatefulWidget {
  final Showtime? showtime;

  const AddEditShowtimeScreen({super.key, this.showtime});

  @override
  State<AddEditShowtimeScreen> createState() => _AddEditShowtimeScreenState();
}

class _AddEditShowtimeScreenState extends State<AddEditShowtimeScreen> {
  final MovieService _movieService = MovieService();
  final HallService _hallService = HallService();
  final ShowtimeService _showtimeService = ShowtimeService();

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _priceController = TextEditingController();

  // ============================================================
  // SELECTED IDs
  //
  // IMPORTANT:
  // We store IDs, NOT Movie/Hall objects.
  //
  // This prevents DropdownButton duplicate-object/value errors.
  // ============================================================

  String? _selectedMovieId;
  String? _selectedHallId;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  bool _saving = false;

  bool get isEditing => widget.showtime != null;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    final showtime = widget.showtime;

    if (showtime != null) {
      _selectedMovieId = showtime.movieId;
      _selectedHallId = showtime.hallId;

      _selectedDate = showtime.date;

      _selectedTime = _parseTime(showtime.startTime);

      _priceController.text = showtime.price.toStringAsFixed(2);
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  // ============================================================
  // PARSE TIME
  // ============================================================

  TimeOfDay? _parseTime(String value) {
    final parts = value.split(':');

    if (parts.length != 2) {
      return null;
    }

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) {
      return null;
    }

    if (hour < 0 || hour > 23) {
      return null;
    }

    if (minute < 0 || minute > 59) {
      return null;
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

  // ============================================================
  // SELECT DATE
  // ============================================================

  Future<void> _selectDate() async {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);

    DateTime initialDate = _selectedDate ?? today;

    if (initialDate.isBefore(today)) {
      initialDate = today;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: today,
      lastDate: DateTime(now.year + 2, 12, 31),
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _selectedDate = picked;
    });
  }

  // ============================================================
  // SELECT TIME
  // ============================================================

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 18, minute: 0),
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _selectedTime = picked;
    });
  }

  // ============================================================
  // FORMAT TIME
  // ============================================================

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');

    final minute = time.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  // ============================================================
  // SAVE SHOWTIME
  // ============================================================

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedMovieId == null || _selectedMovieId!.isEmpty) {
      _showError('Please select a movie.');
      return;
    }

    if (_selectedHallId == null || _selectedHallId!.isEmpty) {
      _showError('Please select a hall.');
      return;
    }

    if (_selectedDate == null) {
      _showError('Please select a date.');
      return;
    }

    if (_selectedTime == null) {
      _showError('Please select a time.');
      return;
    }

    final price = double.tryParse(_priceController.text.trim());

    if (price == null || price < 0) {
      _showError('Please enter a valid ticket price.');
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      // ========================================================
      // LOAD MOVIE
      // ========================================================

      final movies = await _movieService.getMovies().first;

      Movie? selectedMovie;

      for (final movie in movies) {
        if (movie.id == _selectedMovieId) {
          selectedMovie = movie;
          break;
        }
      }

      if (selectedMovie == null) {
        _showError('The selected movie no longer exists.');
        return;
      }

      // ========================================================
      // LOAD HALL
      // ========================================================

      final halls = await _hallService.getHalls().first;

      Hall? selectedHall;

      for (final hall in halls) {
        if (hall.id == _selectedHallId) {
          selectedHall = hall;
          break;
        }
      }

      if (selectedHall == null) {
        _showError('The selected hall no longer exists.');
        return;
      }

      // ========================================================
      // CREATE SHOWTIME
      // ========================================================

      final showtime = Showtime(
        id: widget.showtime?.id ?? '',

        // Movie relationship
        movieId: selectedMovie.id,
        movieTitle: selectedMovie.title,

        // Hall relationship
        hallId: selectedHall.id,
        hallName: selectedHall.name,

        // Date/time
        date: _selectedDate!,

        startTime: _formatTime(_selectedTime!),

        // Price
        price: price,

        // Keep original creation date when editing
        createdAt: widget.showtime?.createdAt,
      );

      // ========================================================
      // UPDATE
      // ========================================================

      if (isEditing) {
        await _showtimeService.updateShowtime(showtime);
      }
      // ========================================================
      // CREATE
      // ========================================================
      else {
        await _showtimeService.addShowtime(showtime);
      }

      if (!mounted) {
        return;
      }

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showError('Failed to save showtime.\n$e');
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  // ============================================================
  // ERROR
  // ============================================================

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // ============================================================
  // MOVIE DROPDOWN
  // ============================================================

  Widget _movieDropdown() {
    return StreamBuilder<List<Movie>>(
      stream: _movieService.getMovies(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Text('Failed to load movies: ${snapshot.error}');
        }

        final movies = snapshot.data ?? [];

        if (movies.isEmpty) {
          return const Text('No movies available.');
        }

        // ======================================================
        // REMOVE DUPLICATE MOVIE IDs
        //
        // DropdownButton requires each value to be unique.
        // ======================================================

        final Map<String, Movie> uniqueMovies = {};

        for (final movie in movies) {
          if (movie.id.isNotEmpty) {
            uniqueMovies[movie.id] = movie;
          }
        }

        final uniqueMovieList = uniqueMovies.values.toList();

        // ======================================================
        // MAKE SURE SELECTED VALUE STILL EXISTS
        // ======================================================

        final movieIds = uniqueMovieList.map((movie) => movie.id).toSet();

        final safeMovieId = movieIds.contains(_selectedMovieId)
            ? _selectedMovieId
            : null;

        return DropdownButtonFormField<String>(
          initialValue: safeMovieId,

          isExpanded: true,

          decoration: const InputDecoration(
            labelText: 'Movie',
            prefixIcon: Icon(Icons.movie_outlined),
            border: OutlineInputBorder(),
          ),

          items: uniqueMovieList.map((movie) {
            return DropdownMenuItem<String>(
              value: movie.id,
              child: Text(movie.title, overflow: TextOverflow.ellipsis),
            );
          }).toList(),

          onChanged: _saving
              ? null
              : (movieId) {
                  setState(() {
                    _selectedMovieId = movieId;
                  });
                },

          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Select a movie';
            }

            return null;
          },
        );
      },
    );
  }

  // ============================================================
  // HALL DROPDOWN
  // ============================================================

  Widget _hallDropdown() {
    return StreamBuilder<List<Hall>>(
      stream: _hallService.getHalls(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Text('Failed to load halls: ${snapshot.error}');
        }

        final halls = snapshot.data ?? [];

        if (halls.isEmpty) {
          return const Text('No halls available.');
        }

        // ======================================================
        // REMOVE DUPLICATE HALL IDs
        // ======================================================

        final Map<String, Hall> uniqueHalls = {};

        for (final hall in halls) {
          if (hall.id.isNotEmpty) {
            uniqueHalls[hall.id] = hall;
          }
        }

        final uniqueHallList = uniqueHalls.values.toList();

        // ======================================================
        // MAKE SURE SELECTED VALUE STILL EXISTS
        // ======================================================

        final hallIds = uniqueHallList.map((hall) => hall.id).toSet();

        final safeHallId = hallIds.contains(_selectedHallId)
            ? _selectedHallId
            : null;

        return DropdownButtonFormField<String>(
          initialValue: safeHallId,

          isExpanded: true,

          decoration: const InputDecoration(
            labelText: 'Hall',
            prefixIcon: Icon(Icons.theaters_outlined),
            border: OutlineInputBorder(),
          ),

          items: uniqueHallList.map((hall) {
            final capacity = hall.rows * hall.seatsPerRow;

            return DropdownMenuItem<String>(
              value: hall.id,
              child: Text(
                '${hall.name} ($capacity seats)',
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),

          onChanged: _saving
              ? null
              : (hallId) {
                  setState(() {
                    _selectedHallId = hallId;
                  });
                },

          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Select a hall';
            }

            return null;
          },
        );
      },
    );
  }

  // ============================================================
  // DATE FIELD
  // ============================================================

  Widget _dateField() {
    return InkWell(
      onTap: _saving ? null : _selectDate,
      borderRadius: BorderRadius.circular(8),

      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Date',
          prefixIcon: Icon(Icons.calendar_today_outlined),
          border: OutlineInputBorder(),
        ),

        child: Text(
          _selectedDate == null
              ? 'Select date'
              : '${_selectedDate!.day.toString().padLeft(2, '0')}/'
                    '${_selectedDate!.month.toString().padLeft(2, '0')}/'
                    '${_selectedDate!.year}',
        ),
      ),
    );
  }

  // ============================================================
  // TIME FIELD
  // ============================================================

  Widget _timeField() {
    return InkWell(
      onTap: _saving ? null : _selectTime,
      borderRadius: BorderRadius.circular(8),

      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Start Time',
          prefixIcon: Icon(Icons.access_time_outlined),
          border: OutlineInputBorder(),
        ),

        child: Text(
          _selectedTime == null
              ? 'Select time'
              : _selectedTime!.format(context),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Showtime' : 'Add Showtime')),

      body: Form(
        key: _formKey,

        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,

              children: [
                // ==================================================
                // MOVIE
                // ==================================================
                _movieDropdown(),

                const SizedBox(height: 20),

                // ==================================================
                // HALL
                // ==================================================
                _hallDropdown(),

                const SizedBox(height: 20),

                // ==================================================
                // DATE
                // ==================================================
                _dateField(),

                const SizedBox(height: 20),

                // ==================================================
                // TIME
                // ==================================================
                _timeField(),

                const SizedBox(height: 20),

                // ==================================================
                // PRICE
                // ==================================================
                TextFormField(
                  controller: _priceController,

                  enabled: !_saving,

                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),

                  decoration: const InputDecoration(
                    labelText: 'Ticket Price',
                    prefixIcon: Icon(Icons.payments_outlined),
                    border: OutlineInputBorder(),
                    prefixText: '\$ ',
                  ),

                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter ticket price';
                    }

                    final price = double.tryParse(value.trim());

                    if (price == null) {
                      return 'Enter a valid price';
                    }

                    if (price < 0) {
                      return 'Price cannot be negative';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 35),

                // ==================================================
                // SAVE
                // ==================================================
                SizedBox(
                  height: 52,

                  child: ElevatedButton.icon(
                    onPressed: _saving ? null : _save,

                    icon: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),

                    label: Text(
                      _saving
                          ? 'Saving...'
                          : isEditing
                          ? 'Update Showtime'
                          : 'Create Showtime',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
