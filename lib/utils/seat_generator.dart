import '../models/hall.dart';

List<HallSeat> generateSeats({required int rows, required int seatsPerRow}) {
  final List<HallSeat> seats = [];

  for (int rowIndex = 0; rowIndex < rows; rowIndex++) {
    final String row = String.fromCharCode('A'.codeUnitAt(0) + rowIndex);

    for (int seatNumber = 1; seatNumber <= seatsPerRow; seatNumber++) {
      seats.add(HallSeat(id: '$row$seatNumber', row: row, number: seatNumber));
    }
  }

  return seats;
}
