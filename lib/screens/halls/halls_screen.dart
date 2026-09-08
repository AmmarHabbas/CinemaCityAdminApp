import 'package:cinema_admin/models/hall.dart';
import 'package:cinema_admin/services/hall_service.dart';
import 'package:flutter/material.dart';

import 'add_edit_hall_screen.dart';

class HallsScreen extends StatefulWidget {
  const HallsScreen({super.key});

  @override
  State<HallsScreen> createState() => _HallsScreenState();
}

class _HallsScreenState extends State<HallsScreen> {
  final HallService _hallService = HallService();

  // ============================================================
  // ADD HALL
  // ============================================================

  Future<void> _addHall() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEditHallScreen()),
    );
  }

  // ============================================================
  // EDIT HALL
  // ============================================================

  Future<void> _editHall(Hall hall) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEditHallScreen(hall: hall)),
    );
  }

  // ============================================================
  // DELETE HALL
  // ============================================================

  Future<void> _deleteHall(Hall hall) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Hall'),
          content: Text('Are you sure you want to delete "${hall.name}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await _hallService.deleteHall(hall.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${hall.name} deleted successfully.')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete hall: $e')));
    }
  }

  // ============================================================
  // HALL CARD
  // ============================================================

  Widget _buildHallCard(Hall hall) {
    final int capacity = hall.rows * hall.seatsPerRow;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Hall icon
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ),
              child: Icon(
                Icons.theaters_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: 28,
              ),
            ),

            const SizedBox(width: 16),

            // Hall information
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hall.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    '${hall.rows} rows • '
                    '${hall.seatsPerRow} seats/row • '
                    '$capacity seats',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
            ),

            // Edit button
            IconButton(
              tooltip: 'Edit Hall',
              onPressed: () => _editHall(hall),
              icon: const Icon(Icons.edit_outlined),
            ),

            // Delete button
            IconButton(
              tooltip: 'Delete Hall',
              onPressed: () => _deleteHall(hall),
              icon: const Icon(Icons.delete_outline),
            ),
          ],
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
      appBar: AppBar(title: const Text('Halls')),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addHall,
        icon: const Icon(Icons.add),
        label: const Text('Add Hall'),
      ),

      body: StreamBuilder<List<Hall>>(
        stream: _hallService.getHalls(),

        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error
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
                      'Failed to load halls',
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

          final halls = snapshot.data ?? [];

          // No halls
          if (halls.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.theaters_outlined,
                    size: 70,
                    color: Colors.grey.shade400,
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'No halls yet',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Add your first cinema hall.',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton.icon(
                    onPressed: _addHall,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Hall'),
                  ),
                ],
              ),
            );
          }

          // Halls list
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: halls.length,
            itemBuilder: (context, index) {
              return _buildHallCard(halls[index]);
            },
          );
        },
      ),
    );
  }
}
