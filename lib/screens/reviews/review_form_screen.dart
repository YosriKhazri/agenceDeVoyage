import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/review_controller.dart';
import '../../controllers/destination_controller.dart';
import '../../controllers/client_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../core/utils/validators.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/star_rating_widget.dart';
import '../../core/router/app_router.dart';

class ReviewFormScreen extends StatefulWidget {
  const ReviewFormScreen({super.key});

  @override
  State<ReviewFormScreen> createState() => _ReviewFormScreenState();
}

class _ReviewFormScreenState extends State<ReviewFormScreen> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedClientId;
  int? _selectedDestinationId;
  int _rating = 0;
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authController = context.read<AuthController>();
      context.read<DestinationController>().loadDestinations();
      // For regular users, auto-populate client ID
      if (!authController.isAdmin && authController.currentUserId != null) {
        _selectedClientId = authController.currentUserId;
      } else {
        context.read<ClientController>().loadClients();
      }
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Review')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Consumer2<AuthController, ClientController>(
                builder: (context, authController, clientController, child) {
                  final isAdmin = authController.isAdmin;
                  final currentUser = authController.currentUser;
                  
                  // For regular users, show read-only field with their name
                  if (!isAdmin && currentUser != null) {
                    return TextFormField(
                      initialValue: currentUser.fullName,
                      decoration: const InputDecoration(
                        labelText: 'Client *',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      enabled: false,
                    );
                  }
                  
                  // For admin, show dropdown
                  return DropdownButtonFormField<int>(
                    value: _selectedClientId,
                    decoration: const InputDecoration(
                      labelText: 'Client *',
                      border: OutlineInputBorder(),
                    ),
                    items: clientController.clients.map((client) {
                      return DropdownMenuItem(
                        value: client.id,
                        child: Text(client.fullName),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedClientId = value),
                    validator: (value) => value == null ? 'Please select a client' : null,
                  );
                },
              ),
              const SizedBox(height: 16),
              Consumer<DestinationController>(
                builder: (context, controller, child) {
                  return DropdownButtonFormField<int>(
                    value: _selectedDestinationId,
                    decoration: const InputDecoration(
                      labelText: 'Destination *',
                      border: OutlineInputBorder(),
                    ),
                    items: controller.destinations.map((destination) {
                      return DropdownMenuItem(
                        value: destination.id,
                        child: Text('${destination.name} - ${destination.country}'),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedDestinationId = value),
                    validator: (value) => value == null ? 'Please select a destination' : null,
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text('Rating *', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              StarRatingWidget(
                rating: _rating,
                size: 40,
                onRatingChanged: (rating) => setState(() => _rating = rating),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Comment',
                controller: _commentController,
                maxLines: 5,
              ),
              const SizedBox(height: 24),
              Consumer<ReviewController>(
                builder: (context, controller, child) {
                  return CustomButton(
                    text: 'Create Review',
                    isLoading: controller.isLoading,
                    onPressed: () => _handleSubmit(context, controller),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit(BuildContext context, ReviewController controller) async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating'), backgroundColor: Colors.red),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;
    if (_selectedClientId == null || _selectedDestinationId == null) return;

    final success = await controller.createReview(
      destinationId: _selectedDestinationId!,
      clientId: _selectedClientId!,
      rating: _rating,
      comment: _commentController.text.trim().isEmpty ? null : _commentController.text.trim(),
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review created successfully')),
        );
        AppRouter.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(controller.error ?? 'An error occurred'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

