import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/client_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/client_card.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../core/router/app_router.dart';
import 'client_form_screen.dart';
import 'client_detail_screen.dart';

class ClientsListScreen extends StatefulWidget {
  const ClientsListScreen({super.key});

  @override
  State<ClientsListScreen> createState() => _ClientsListScreenState();
}

class _ClientsListScreenState extends State<ClientsListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClientController>().loadClients();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, authController, child) {
        // Only show for admin
        if (!authController.isAdmin) {
          return Scaffold(
            appBar: AppBar(title: const Text('Clients')),
            body: const Center(
              child: Text('Access denied. Admin only.'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Users'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () async {
                  final result = await AppRouter.navigateToClientForm(context);
                  if (result == true && mounted) {
                    context.read<ClientController>().loadClients();
                  }
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
                hintText: 'Search clients...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<ClientController>().clearFilters();
                        },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (value) {
                context.read<ClientController>().searchClients(value);
              },
            ),
          ),
          Expanded(
            child: Consumer<ClientController>(
              builder: (context, controller, child) {
                if (controller.isLoading && controller.clients.isEmpty) {
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
                          onPressed: () => controller.loadClients(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (controller.clients.isEmpty) {
                  return EmptyState(
                    message: 'No clients found',
                    actionLabel: 'Add Client',
                    onAction: () async {
                      final result = await AppRouter.navigateToClientForm(context);
                      if (result == true && mounted) {
                        controller.loadClients();
                      }
                    },
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => controller.loadClients(),
                  child: ListView.builder(
                    itemCount: controller.clients.length,
                    itemBuilder: (context, index) {
                      final client = controller.clients[index];
                      return ClientCard(
                        client: client,
                        onTap: () {
                          AppRouter.navigateToClientDetail(context, client.id!);
                        },
                        onEdit: () async {
                          final result = await AppRouter.navigateToClientForm(
                            context,
                            client: client,
                          );
                          if (result == true && mounted) {
                            controller.loadClients();
                          }
                        },
                        onDelete: () {
                          _showDeleteDialog(context, controller, client.id!);
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
      },
    );
  }

  void _showDeleteDialog(BuildContext context, ClientController controller, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Client'),
        content: const Text('Are you sure you want to delete this client?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await controller.deleteClient(id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(success ? 'Client deleted' : 'Failed to delete client')),
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

