import '../database/database_constants.dart';

enum ReservationStatus {
  pending,
  confirmed,
  cancelled,
  completed;

  static ReservationStatus fromString(String value) {
    return ReservationStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ReservationStatus.pending,
    );
  }

  String get displayName {
    switch (this) {
      case ReservationStatus.pending:
        return 'Pending';
      case ReservationStatus.confirmed:
        return 'Confirmed';
      case ReservationStatus.cancelled:
        return 'Cancelled';
      case ReservationStatus.completed:
        return 'Completed';
    }
  }
}

class Reservation {
  final int? id;
  final int clientId;
  final int destinationId;
  final String departureDate;
  final String returnDate;
  final int numberOfGuests;
  final double totalPrice;
  final ReservationStatus status;
  final String? notes;
  final String createdAt;
  final String updatedAt;

  Reservation({
    this.id,
    required this.clientId,
    required this.destinationId,
    required this.departureDate,
    required this.returnDate,
    required this.numberOfGuests,
    required this.totalPrice,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      DatabaseConstants.columnId: id,
      DatabaseConstants.columnReservationClientId: clientId,
      DatabaseConstants.columnReservationDestinationId: destinationId,
      DatabaseConstants.columnReservationDepartureDate: departureDate,
      DatabaseConstants.columnReservationReturnDate: returnDate,
      DatabaseConstants.columnReservationNumberOfGuests: numberOfGuests,
      DatabaseConstants.columnReservationTotalPrice: totalPrice,
      DatabaseConstants.columnReservationStatus: status.name,
      DatabaseConstants.columnReservationNotes: notes,
      DatabaseConstants.columnCreatedAt: createdAt,
      DatabaseConstants.columnUpdatedAt: updatedAt,
    };
  }

  factory Reservation.fromMap(Map<String, dynamic> map) {
    return Reservation(
      id: map[DatabaseConstants.columnId] as int?,
      clientId: map[DatabaseConstants.columnReservationClientId] as int,
      destinationId: map[DatabaseConstants.columnReservationDestinationId] as int,
      departureDate: map[DatabaseConstants.columnReservationDepartureDate] as String,
      returnDate: map[DatabaseConstants.columnReservationReturnDate] as String,
      numberOfGuests: map[DatabaseConstants.columnReservationNumberOfGuests] as int,
      totalPrice: (map[DatabaseConstants.columnReservationTotalPrice] as num).toDouble(),
      status: ReservationStatus.fromString(
        map[DatabaseConstants.columnReservationStatus] as String,
      ),
      notes: map[DatabaseConstants.columnReservationNotes] as String?,
      createdAt: map[DatabaseConstants.columnCreatedAt] as String,
      updatedAt: map[DatabaseConstants.columnUpdatedAt] as String,
    );
  }

  Reservation copyWith({
    int? id,
    int? clientId,
    int? destinationId,
    String? departureDate,
    String? returnDate,
    int? numberOfGuests,
    double? totalPrice,
    ReservationStatus? status,
    String? notes,
    String? createdAt,
    String? updatedAt,
  }) {
    return Reservation(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      destinationId: destinationId ?? this.destinationId,
      departureDate: departureDate ?? this.departureDate,
      returnDate: returnDate ?? this.returnDate,
      numberOfGuests: numberOfGuests ?? this.numberOfGuests,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

