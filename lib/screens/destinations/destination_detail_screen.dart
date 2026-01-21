import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/destination_controller.dart';
import '../../widgets/common/loading_indicator.dart';

class DestinationDetailScreen extends StatefulWidget {
  final int destinationId;

  const DestinationDetailScreen({super.key, required this.destinationId});

  @override
  State<DestinationDetailScreen> createState() => _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends State<DestinationDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final controller = context.read<DestinationController>();
      final destination = await controller.getDestinationById(widget.destinationId);
      if (destination != null && mounted) {
        controller.selectDestination(destination);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Destination Details'),
      ),
      body: Consumer<DestinationController>(
        builder: (context, controller, child) {
          final destination = controller.selectedDestination;

          if (destination == null) {
            return const LoadingIndicator();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (destination.imageUrl != null && destination.imageUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      destination.imageUrl!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, size: 64),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  destination.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      destination.city != null && destination.city!.isNotEmpty
                          ? '${destination.city}, ${destination.country}'
                          : destination.country,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Base Price',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '\$${destination.basePrice.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
                if (destination.description != null && destination.description!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    destination.description!,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

