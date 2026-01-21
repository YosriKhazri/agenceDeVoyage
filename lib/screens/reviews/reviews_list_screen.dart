import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/review_controller.dart';
import '../../controllers/destination_controller.dart';
import '../../controllers/client_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../core/models/destination.dart';
import '../../core/models/client.dart';
import '../../widgets/review_card.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../core/router/app_router.dart';
import 'review_form_screen.dart';

class ReviewsListScreen extends StatefulWidget {
  const ReviewsListScreen({super.key});

  @override
  State<ReviewsListScreen> createState() => _ReviewsListScreenState();
}

class _ReviewsListScreenState extends State<ReviewsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewController>().loadReviews();
      context.read<DestinationController>().loadDestinations();
      context.read<ClientController>().loadClients();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reviews'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await AppRouter.navigateToReviewForm(context);
              if (result == true && mounted) {
                context.read<ReviewController>().loadReviews();
              }
            },
          ),
        ],
      ),
      body: Consumer<ReviewController>(
        builder: (context, controller, child) {
          if (controller.isLoading && controller.reviews.isEmpty) {
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
                    onPressed: () => controller.loadReviews(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (controller.reviews.isEmpty) {
            return EmptyState(
              message: 'No reviews found',
              actionLabel: 'Add Review',
              onAction: () async {
                final result = await AppRouter.navigateToReviewForm(context);
                if (result == true && mounted) {
                  controller.loadReviews();
                }
              },
            );
          }

          return RefreshIndicator(
            onRefresh: () => controller.loadReviews(),
            child: ListView.builder(
              itemCount: controller.reviews.length,
              itemBuilder: (context, index) {
                final review = controller.reviews[index];
                return Consumer2<DestinationController, ClientController>(
                  builder: (context, destController, clientController, child) {
                    Destination? destination;
                    try {
                      destination = destController.destinations
                          .firstWhere((d) => d.id == review.destinationId);
                    } catch (e) {
                      destination = null;
                    }
                    Client? client;
                    try {
                      client = clientController.clients
                          .firstWhere((c) => c.id == review.clientId);
                    } catch (e) {
                      client = null;
                    }

                    return Consumer<AuthController>(
                      builder: (context, authController, child) {
                        return FutureBuilder<bool>(
                          future: controller.canUserModifyReview(
                            review.id!,
                            authController.currentUserId ?? 0,
                            authController.isAdmin,
                          ),
                          builder: (context, snapshot) {
                            final canModify = snapshot.data ?? false;
                            return ReviewCard(
                              review: review,
                              destinationName: destination?.name,
                              clientName: client?.fullName,
                              // Admin can only delete, not edit. Users can edit their own reviews.
                              onEdit: canModify && !authController.isAdmin
                                  ? () async {
                                      // TODO: Implement edit review for users
                                    }
                                  : null,
                              onDelete: canModify
                                  ? () {
                                      _showDeleteDialog(context, controller, review.id!);
                                    }
                                  : null,
                            );
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
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ReviewController controller, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Review'),
        content: const Text('Are you sure you want to delete this review?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await controller.deleteReview(id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(success ? 'Review deleted' : 'Failed to delete review')),
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

