import 'package:flutter/material.dart';

import '../../models/showtime.dart';
import '../../services/showtime_service.dart';

import 'add_edit_showtime_screen.dart';

class ShowtimesScreen extends StatefulWidget {
  const ShowtimesScreen({super.key});

  @override
  State<ShowtimesScreen> createState() => _ShowtimesScreenState();
}

class _ShowtimesScreenState extends State<ShowtimesScreen> {
  final ShowtimeService _showtimeService = ShowtimeService();

  // ============================================================
  // ADD
  // ============================================================

  Future<void> _addShowtime() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEditShowtimeScreen()),
    );
  }

  // ============================================================
  // EDIT
  // ============================================================

  Future<void> _editShowtime(Showtime showtime) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditShowtimeScreen(showtime: showtime),
      ),
    );
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> _deleteShowtime(Showtime showtime) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Showtime'),

          content: Text(
            'Delete ${showtime.movieTitle} '
            'at ${showtime.startTime}?',
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _showtimeService.deleteShowtime(showtime.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Showtime deleted successfully.')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete showtime: $e')));
    }
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  // ============================================================
  // SHOWTIME CARD
  // ============================================================

  Widget _buildShowtimeCard(Showtime showtime) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),

      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Row(
          children: [
            // ==================================================
            // DATE
            // ==================================================
            Container(
              width: 75,
              padding: const EdgeInsets.symmetric(vertical: 12),

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),

                color: Theme.of(context).colorScheme.primary.withOpacity(.1),
              ),

              child: Column(
                children: [
                  Text(
                    showtime.date.day.toString().padLeft(2, '0'),

                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  Text(
                    _monthName(showtime.date.month),

                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 18),

            // ==================================================
            // INFORMATION
            // ==================================================
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    showtime.movieTitle,

                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 7),

                  Row(
                    children: [
                      const Icon(Icons.theaters_outlined, size: 16),

                      const SizedBox(width: 5),

                      Text(showtime.hallName),
                    ],
                  ),

                  const SizedBox(height: 5),

                  Row(
                    children: [
                      const Icon(Icons.access_time_outlined, size: 16),

                      const SizedBox(width: 5),

                      Text(showtime.startTime),

                      const SizedBox(width: 15),

                      const Icon(Icons.payments_outlined, size: 16),

                      const SizedBox(width: 5),

                      Text('\$${showtime.price.toStringAsFixed(2)}'),
                    ],
                  ),
                ],
              ),
            ),

            // ==================================================
            // EDIT
            // ==================================================
            IconButton(
              tooltip: 'Edit Showtime',

              onPressed: () => _editShowtime(showtime),

              icon: const Icon(Icons.edit_outlined),
            ),

            // ==================================================
            // DELETE
            // ==================================================
            IconButton(
              tooltip: 'Delete Showtime',

              onPressed: () => _deleteShowtime(showtime),

              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MONTH
  // ============================================================

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return months[month - 1];
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Showtimes')),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addShowtime,

        icon: const Icon(Icons.add),

        label: const Text('Add Showtime'),
      ),

      body: StreamBuilder<List<Showtime>>(
        stream: _showtimeService.getShowtimes(),

        builder: (context, snapshot) {
          // ======================================================
          // LOADING
          // ======================================================

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ======================================================
          // ERROR
          // ======================================================

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    const Icon(Icons.error_outline, size: 50),

                    const SizedBox(height: 12),

                    const Text(
                      'Failed to load showtimes',

                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text('${snapshot.error}', textAlign: TextAlign.center),
                  ],
                ),
              ),
            );
          }

          final showtimes = snapshot.data ?? [];

          // ======================================================
          // EMPTY
          // ======================================================

          if (showtimes.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,

                children: [
                  Icon(
                    Icons.schedule_outlined,
                    size: 70,
                    color: Colors.grey.shade400,
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'No showtimes yet',

                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Create your first movie showtime.',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton.icon(
                    onPressed: _addShowtime,

                    icon: const Icon(Icons.add),

                    label: const Text('Add Showtime'),
                  ),
                ],
              ),
            );
          }

          // ======================================================
          // LIST
          // ======================================================

          return ListView.builder(
            padding: const EdgeInsets.all(20),

            itemCount: showtimes.length,

            itemBuilder: (context, index) {
              return _buildShowtimeCard(showtimes[index]);
            },
          );
        },
      ),
    );
  }
}
