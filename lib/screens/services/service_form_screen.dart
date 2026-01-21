import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/additional_service_controller.dart';
import '../../core/models/additional_service.dart';
import '../../core/utils/validators.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../core/router/app_router.dart';

class ServiceFormScreen extends StatefulWidget {
  final AdditionalService? service;

  const ServiceFormScreen({super.key, this.service});

  @override
  State<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends State<ServiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.service != null) {
      _nameController.text = widget.service!.name;
      _descriptionController.text = widget.service!.description ?? '';
      _priceController.text = widget.service!.price.toString();
      _categoryController.text = widget.service!.category ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.service == null ? 'Add Service' : 'Edit Service'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                label: 'Name *',
                controller: _nameController,
                validator: (value) => Validators.validateRequired(value, 'Name'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Description',
                controller: _descriptionController,
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Price *',
                controller: _priceController,
                keyboardType: TextInputType.number,
                validator: Validators.validatePrice,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Category',
                controller: _categoryController,
                hint: 'e.g., Insurance, Transportation, Guide',
              ),
              const SizedBox(height: 24),
              Consumer<AdditionalServiceController>(
                builder: (context, controller, child) {
                  return CustomButton(
                    text: widget.service == null ? 'Create Service' : 'Update Service',
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

  Future<void> _handleSubmit(BuildContext context, AdditionalServiceController controller) async {
    if (!_formKey.currentState!.validate()) return;

    final success = widget.service == null
        ? await controller.createService(
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            price: double.parse(_priceController.text),
            category: _categoryController.text.trim().isEmpty ? null : _categoryController.text.trim(),
          )
        : await controller.updateService(
            widget.service!.copyWith(
              name: _nameController.text.trim(),
              description: _descriptionController.text.trim().isEmpty
                  ? null
                  : _descriptionController.text.trim(),
              price: double.parse(_priceController.text),
              category: _categoryController.text.trim().isEmpty ? null : _categoryController.text.trim(),
            ),
          );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.service == null ? 'Service created successfully' : 'Service updated successfully',
            ),
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

