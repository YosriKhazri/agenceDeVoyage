import 'package:flutter/material.dart';
import '../core/models/reservation.dart';
import '../core/utils/date_formatter.dart';

class ReservationCard extends StatelessWidget {
  final Reservation reservation;
  final String? clientName;
  final String? destinationName;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onApprove;
  final VoidCallback? onDelete;

  const ReservationCard({
    super.key,
    required this.reservation,
    this.clientName,
    this.destinationName,
    this.onTap,
    this.onEdit,
    this.onApprove,
    this.onDelete,
  });

  Color _getStatusColor(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.pending:
        return Colors.orange;
      case ReservationStatus.confirmed:
        return Colors.green;
      case ReservationStatus.cancelled:
        return Colors.red;
      case ReservationStatus.completed:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (clientName != null)
                          Text(
                            clientName!,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        if (destinationName != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            destinationName!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(reservation.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      reservation.status.displayName,
                      style: TextStyle(
                        color: _getStatusColor(reservation.status),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    DateFormatter.formatDisplayDate(reservation.departureDate),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Text(' - '),
                  Text(
                    DateFormatter.formatDisplayDate(reservation.returnDate),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.people, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        '${reservation.numberOfGuests} guest${reservation.numberOfGuests > 1 ? 's' : ''}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  Text(
                    '\$${reservation.totalPrice.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              if (onEdit != null || onDelete != null || onApprove != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (onApprove != null && reservation.status == ReservationStatus.pending) ...[
                        TextButton.icon(
                          onPressed: onApprove,
                          icon: const Icon(Icons.check_circle, size: 18),
                          label: const Text('Approve'),
                        ),
                        const SizedBox(width: 4),
                      ],
                      if (onEdit != null)
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: onEdit,
                        ),
                      if (onDelete != null)
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                          onPressed: onDelete,
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

