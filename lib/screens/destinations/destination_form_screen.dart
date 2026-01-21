import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:provider/provider.dart';
import '../../controllers/destination_controller.dart';
import '../../core/models/destination.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/constants.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../core/router/app_router.dart';

class DestinationFormScreen extends StatefulWidget {
  final Destination? destination;

  const DestinationFormScreen({super.key, this.destination});

  @override
  State<DestinationFormScreen> createState() => _DestinationFormScreenState();
}

class _DestinationFormScreenState extends State<DestinationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.destination != null) {
      _nameController.text = widget.destination!.name;
      _countryController.text = widget.destination!.country;
      _cityController.text = widget.destination!.city ?? '';
      _imageUrlController.text = widget.destination!.imageUrl ?? '';
      _descriptionController.text = widget.destination!.description ?? '';
      _priceController.text = widget.destination!.basePrice.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _imageUrlController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.destination != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Destination' : 'Add Destination'),
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
              TextFormField(
                controller: _countryController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Country *',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.arrow_drop_down),
                ),
                validator: (value) =>
                    Validators.validateRequired(value, 'Country'),
                onTap: () {
                  showCountryPicker(
                    context: context,
                    showPhoneCode:
                        false, // we only need country name, not phone code
                    onSelect: (Country country) {
                      setState(() {
                        _countryController.text = country.name;
                        _cityController.clear();
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  final country = _countryController.text.trim();
                  if (country.isEmpty) {
                    return const Iterable<String>.empty();
                  }
                  final cities = kCountryCities[country] ?? const [];
                  if (textEditingValue.text.isEmpty) {
                    return cities;
                  }
                  final query = textEditingValue.text.toLowerCase();
                  return cities.where(
                    (city) => city.toLowerCase().contains(query),
                  );
                },
                onSelected: (String selection) {
                  _cityController.text = selection;
                },
                fieldViewBuilder: (
                  BuildContext context,
                  TextEditingController fieldController,
                  FocusNode focusNode,
                  VoidCallback onFieldSubmitted,
                ) {
                  fieldController.text = _cityController.text;

                  return TextFormField(
                    controller: fieldController,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'City / Place',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      _cityController.text = value;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Image URL',
                controller: _imageUrlController,
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Description',
                controller: _descriptionController,
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Base Price *',
                controller: _priceController,
                keyboardType: TextInputType.number,
                validator: Validators.validatePrice,
              ),
              const SizedBox(height: 24),
              Consumer<DestinationController>(
                builder: (context, controller, child) {
                  return CustomButton(
                    text: isEdit ? 'Update Destination' : 'Create Destination',
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

  Future<void> _handleSubmit(
    BuildContext context,
    DestinationController controller,
  ) async {
    if (!_formKey.currentState!.validate()) return;

    final success = widget.destination == null
        ? await controller.createDestination(
            name: _nameController.text.trim(),
            country: _countryController.text.trim(),
            city: _cityController.text.trim().isEmpty
                ? null
                : _cityController.text.trim(),
            imageUrl: _imageUrlController.text.trim().isEmpty
                ? null
                : _imageUrlController.text.trim(),
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            basePrice: double.parse(_priceController.text),
          )
        : await controller.updateDestination(
            widget.destination!.copyWith(
              name: _nameController.text.trim(),
              country: _countryController.text.trim(),
              city: _cityController.text.trim().isEmpty
                  ? null
                  : _cityController.text.trim(),
              imageUrl: _imageUrlController.text.trim().isEmpty
                  ? null
                  : _imageUrlController.text.trim(),
              description: _descriptionController.text.trim().isEmpty
                  ? null
                  : _descriptionController.text.trim(),
              basePrice: double.parse(_priceController.text),
            ),
          );

    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.destination == null
                  ? 'Destination created successfully'
                  : 'Destination updated successfully',
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

