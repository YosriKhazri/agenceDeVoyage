import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/client_controller.dart';
import '../../core/models/client.dart';
import '../../core/utils/validators.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../core/router/app_router.dart';

class ClientFormScreen extends StatefulWidget {
  final Client? client;

  const ClientFormScreen({super.key, this.client});

  @override
  State<ClientFormScreen> createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends State<ClientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passportController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.client != null) {
      _firstNameController.text = widget.client!.firstName;
      _lastNameController.text = widget.client!.lastName;
      _emailController.text = widget.client!.email;
      _passportController.text = widget.client!.passportNumber;
      _phoneController.text = widget.client!.phone ?? '';
      _addressController.text = widget.client!.address ?? '';
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passportController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.client == null ? 'Add Client' : 'Edit Client'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                label: 'First Name *',
                controller: _firstNameController,
                validator: (value) => Validators.validateRequired(value, 'First Name'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Last Name *',
                controller: _lastNameController,
                validator: (value) => Validators.validateRequired(value, 'Last Name'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Email *',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Passport Number *',
                controller: _passportController,
                validator: (value) => Validators.validateRequired(value, 'Passport Number'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Phone',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Address',
                controller: _addressController,
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Consumer<ClientController>(
                builder: (context, controller, child) {
                  return CustomButton(
                    text: widget.client == null ? 'Create Client' : 'Update Client',
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

  Future<void> _handleSubmit(BuildContext context, ClientController controller) async {
    if (!_formKey.currentState!.validate()) return;

    final success = widget.client == null
        ? await controller.createClient(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            email: _emailController.text.trim(),
            passportNumber: _passportController.text.trim(),
            phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
            address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
          )
        : await controller.updateClient(
            widget.client!.copyWith(
              firstName: _firstNameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              email: _emailController.text.trim(),
              passportNumber: _passportController.text.trim(),
              phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
              address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
            ),
          );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.client == null ? 'Client created successfully' : 'Client updated successfully'),
          ),
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

