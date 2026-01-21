import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/destination_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/destination_card.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../core/router/app_router.dart';
import 'destination_form_screen.dart';
import 'destination_detail_screen.dart';

class DestinationsListScreen extends StatefulWidget {
  const DestinationsListScreen({super.key});

  @override
  State<DestinationsListScreen> createState() => _DestinationsListScreenState();
}

class _DestinationsListScreenState extends State<DestinationsListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DestinationController>().loadDestinations();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Destinations'),
        actions: [
          Consumer<AuthController>(
            builder: (context, authController, child) {
              if (authController.isAdmin) {
                return IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () async {
                    final result = await AppRouter.navigateToDestinationForm(context);
                    if (result == true) {
                      context.read<DestinationController>().loadDestinations();
                    }
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search destinations...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<DestinationController>().clearFilters();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                context.read<DestinationController>().searchDestinations(value);
              },
            ),
          ),
          Expanded(
            child: Consumer<DestinationController>(
              builder: (context, controller, child) {
                if (controller.isLoading && controller.destinations.isEmpty) {
                  return const LoadingIndicator();
                }

                if (controller.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Error: ${controller.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => controller.loadDestinations(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (controller.destinations.isEmpty) {
                  return EmptyState(
                    message: 'No destinations found',
                    actionLabel: 'Add Destination',
                    onAction: () async {
                      final result = await AppRouter.navigateToDestinationForm(context);
                      if (result == true) {
                        controller.loadDestinations();
                      }
                    },
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => controller.loadDestinations(),
                  child: ListView.builder(
                    itemCount: controller.destinations.length,
                    itemBuilder: (context, index) {
                      final destination = controller.destinations[index];
                      return Consumer<AuthController>(
                        builder: (context, authController, child) {
                          return DestinationCard(
                            destination: destination,
                            onTap: () {
                              AppRouter.navigateToDestinationDetail(context, destination.id!);
                            },
                            onEdit: authController.isAdmin
                                ? () async {
                                    final result = await AppRouter.navigateToDestinationForm(
                                      context,
                                      destination: destination,
                                    );
                                    if (result == true) {
                                      controller.loadDestinations();
                                    }
                                  }
                                : null,
                            onDelete: authController.isAdmin
                                ? () {
                                    _showDeleteDialog(context, controller, destination.id!);
                                  }
                                : null,
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    DestinationController controller,
    int id,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Destination'),
        content: const Text('Are you sure you want to delete this destination?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await controller.deleteDestination(id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? 'Destination deleted' : 'Failed to delete destination',
                    ),
                  ),
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

