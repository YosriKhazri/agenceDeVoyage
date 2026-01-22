import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/reservation_controller.dart';
import '../../controllers/destination_controller.dart';
import '../../controllers/client_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../core/models/reservation.dart';
import '../../core/models/destination.dart';
import '../../core/models/client.dart';
import '../../widgets/reservation_card.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../core/router/app_router.dart';
import 'reservation_form_screen.dart';

class ReservationsListScreen extends StatefulWidget {
  const ReservationsListScreen({super.key});

  @override
  State<ReservationsListScreen> createState() => _ReservationsListScreenState();
}

class _ReservationsListScreenState extends State<ReservationsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authController = context.read<AuthController>();
      context.read<ReservationController>().loadReservations(
        userId: authController.currentUserId,
        isAdmin: authController.isAdmin,
      );
      context.read<DestinationController>().loadDestinations();
      if (authController.isAdmin) {
        context.read<ClientController>().loadClients();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final authController = context.read<AuthController>();
              final result = await AppRouter.navigateToReservationForm(context);
              if (result == true && mounted) {
                context.read<ReservationController>().loadReservations(
                  userId: authController.currentUserId,
                  isAdmin: authController.isAdmin,
                );
              }
            },
          ),
        ],
      ),
      body: Consumer<ReservationController>(
        builder: (context, controller, child) {
          if (controller.isLoading && controller.reservations.isEmpty) {
            return const LoadingIndicator();
          }

          if (controller.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${controller.error}', style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.loadReservations(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (controller.reservations.isEmpty) {
            return EmptyState(
              message: 'No reservations found',
              actionLabel: 'Create Reservation',
              onAction: () async {
                final authController = context.read<AuthController>();
                final result = await AppRouter.navigateToReservationForm(context);
                if (result == true && mounted) {
                  controller.loadReservations(
                    userId: authController.currentUserId,
                    isAdmin: authController.isAdmin,
                  );
                }
              },
            );
          }

          return Consumer<AuthController>(
            builder: (context, authController, child) {
              return RefreshIndicator(
                onRefresh: () => controller.loadReservations(
                  userId: authController.currentUserId,
                  isAdmin: authController.isAdmin,
                ),
                child: ListView.builder(
              itemCount: controller.reservations.length,
              itemBuilder: (context, index) {
                final reservation = controller.reservations[index];
                return Consumer2<DestinationController, ClientController>(
                  builder: (context, destController, clientController, child) {
                    Destination? destination;
                    try {
                      destination = destController.destinations
                          .firstWhere((d) => d.id == reservation.destinationId);
                    } catch (e) {
                      destination = null;
                    }
                    Client? client;
                    try {
                      client = clientController.clients
                          .firstWhere((c) => c.id == reservation.clientId);
                    } catch (e) {
                      client = null;
                    }

                    return Consumer<AuthController>(
                      builder: (context, authController, child) {
                        final isAdmin = authController.isAdmin;
                        return ReservationCard(
                          reservation: reservation,
                          destinationName: destination?.name,
                          clientName: isAdmin ? client?.fullName : null,
                          onApprove: isAdmin && reservation.status == ReservationStatus.pending
                              ? () async {
                                  final success = await controller.approveReservation(reservation);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(success ? 'Reservation approved' : (controller.error ?? 'Failed to approve')),
                                        backgroundColor: success ? null : Colors.red,
                                      ),
                                    );
                                  }
                                }
                              : null,
                          onEdit: () async {
                            final result = await AppRouter.navigateToReservationForm(
                              context,
                              reservation: reservation,
                            );
                            if (result == true && mounted) {
                              controller.loadReservations(
                                userId: authController.currentUserId,
                                isAdmin: authController.isAdmin,
                              );
                            }
                          },
                          onDelete: () {
                            _showDeleteDialog(context, controller, reservation.id!);
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
              );
            },
          );
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ReservationController controller, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reservation'),
        content: const Text('Are you sure you want to delete this reservation?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await controller.deleteReservation(id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(success ? 'Reservation deleted' : 'Failed to delete reservation')),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

