import 'package:cinema_admin/models/hall.dart';
import 'package:cinema_admin/services/hall_service.dart';
import 'package:flutter/material.dart';

class AddEditHallScreen extends StatefulWidget {
  final Hall? hall;

  const AddEditHallScreen({super.key, this.hall});

  @override
  State<AddEditHallScreen> createState() => _AddEditHallScreenState();
}

class _AddEditHallScreenState extends State<AddEditHallScreen> {
  final HallService _hallService = HallService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _rowsController = TextEditingController();
  final TextEditingController _seatsPerRowController = TextEditingController();

  bool _isSaving = false;

  bool get _isEditing => widget.hall != null;

  @override
  void initState() {
    super.initState();

    if (widget.hall != null) {
      _nameController.text = widget.hall!.name;
      _rowsController.text = widget.hall!.rows.toString();
      _seatsPerRowController.text = widget.hall!.seatsPerRow.toString();
    }
  }

  // ============================================================
  // GENERATE SEATS
  // ============================================================

  List<HallSeat> generateSeats({required int rows, required int seatsPerRow}) {
    final List<HallSeat> seats = [];

    for (int rowIndex = 0; rowIndex < rows; rowIndex++) {
      final String row = String.fromCharCode('A'.codeUnitAt(0) + rowIndex);

      for (int seatNumber = 1; seatNumber <= seatsPerRow; seatNumber++) {
        seats.add(
          HallSeat(id: '$row$seatNumber', row: row, number: seatNumber),
        );
      }
    }

    return seats;
  }

  // ============================================================
  // SAVE HALL
  // ============================================================

  Future<void> _saveHall() async {
    final name = _nameController.text.trim();

    final rows = int.tryParse(_rowsController.text.trim());

    final seatsPerRow = int.tryParse(_seatsPerRowController.text.trim());

    if (name.isEmpty || rows == null || seatsPerRow == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields correctly.')),
      );
      return;
    }

    if (rows <= 0 || seatsPerRow <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rows and seats per row must be greater than 0.'),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final seats = generateSeats(rows: rows, seatsPerRow: seatsPerRow);

      if (_isEditing) {
        // UPDATE EXISTING HALL
        final updatedHall = Hall(
          id: widget.hall!.id,
          name: name,
          rows: rows,
          seatsPerRow: seatsPerRow,
          seats: seats,
          createdAt: widget.hall!.createdAt,
        );

        await _hallService.updateHall(updatedHall);
      } else {
        // ADD NEW HALL
        final newHall = Hall(
          id: '',
          name: name,
          rows: rows,
          seatsPerRow: seatsPerRow,
          seats: seats,
        );

        await _hallService.addHall(newHall);
      }

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to ${_isEditing ? 'update' : 'save'} hall: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _nameController.dispose();
    _rowsController.dispose();
    _seatsPerRowController.dispose();
    super.dispose();
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Hall' : 'Add Hall')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Hall Name',
                hintText: 'e.g. Hall 1',
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _rowsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Rows',
                hintText: 'e.g. 8',
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _seatsPerRowController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Seats Per Row',
                hintText: 'e.g. 12',
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveHall,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEditing ? 'Update Hall' : 'Save Hall'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
