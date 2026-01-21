import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/additional_service_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../core/router/app_router.dart';
import 'service_form_screen.dart';

class ServicesListScreen extends StatefulWidget {
  const ServicesListScreen({super.key});

  @override
  State<ServicesListScreen> createState() => _ServicesListScreenState();
}

class _ServicesListScreenState extends State<ServicesListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdditionalServiceController>().loadServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Additional Services'),
        actions: [
          Consumer<AuthController>(
            builder: (context, authController, child) {
              if (authController.isAdmin) {
                return IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () async {
                    final result = await AppRouter.navigateToServiceForm(context);
                    if (result == true && mounted) {
                      context.read<AdditionalServiceController>().loadServices();
                    }
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<AdditionalServiceController>(
        builder: (context, controller, child) {
          if (controller.isLoading && controller.services.isEmpty) {
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
                    onPressed: () => controller.loadServices(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (controller.services.isEmpty) {
            return EmptyState(
              message: 'No services found',
              actionLabel: 'Add Service',
              onAction: () async {
                final result = await AppRouter.navigateToServiceForm(context);
                if (result == true && mounted) {
                  controller.loadServices();
                }
              },
            );
          }

          return RefreshIndicator(
            onRefresh: () => controller.loadServices(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.services.length,
              itemBuilder: (context, index) {
                final service = controller.services[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              if (service.description != null && service.description!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  service.description!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              if (service.category != null && service.category!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Chip(
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                    label: Text(service.category!),
                                    labelStyle: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\$${service.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            Consumer<AuthController>(
                              builder: (context, authController, child) {
                                if (authController.isAdmin) {
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        visualDensity: VisualDensity.compact,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        icon: const Icon(Icons.edit, size: 20),
                                        onPressed: () async {
                                          final result = await AppRouter.navigateToServiceForm(
                                            context,
                                            service: service,
                                          );
                                          if (result == true && mounted) {
                                            controller.loadServices();
                                          }
                                        },
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        visualDensity: VisualDensity.compact,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                        onPressed: () {
                                          _showDeleteDialog(context, controller, service.id!);
                                        },
                                      ),
                                    ],
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, AdditionalServiceController controller, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service'),
        content: const Text('Are you sure you want to delete this service?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await controller.deleteService(id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(success ? 'Service deleted' : 'Failed to delete service')),
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

