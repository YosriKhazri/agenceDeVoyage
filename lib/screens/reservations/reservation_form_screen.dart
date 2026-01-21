import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/reservation_controller.dart';
import '../../controllers/destination_controller.dart';
import '../../controllers/client_controller.dart';
import '../../controllers/additional_service_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../core/models/reservation.dart';
import '../../core/utils/validators.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../core/router/app_router.dart';

class ReservationFormScreen extends StatefulWidget {
  final Reservation? reservation;

  const ReservationFormScreen({super.key, this.reservation});

  @override
  State<ReservationFormScreen> createState() => _ReservationFormScreenState();
}

class _ReservationFormScreenState extends State<ReservationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedClientId;
  int? _selectedDestinationId;
  ReservationStatus _status = ReservationStatus.pending;
  final _departureDateController = TextEditingController();
  final _returnDateController = TextEditingController();
  final _guestsController = TextEditingController(text: '1');
  final _notesController = TextEditingController();
  final Set<int> _selectedServiceIds = {};
  double _totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DestinationController>().loadDestinations();
      context.read<ClientController>().loadClients();
      context.read<AdditionalServiceController>().loadServices();
      _initEditMode();
    });
  }

  Future<void> _initEditMode() async {
    final reservation = widget.reservation;
    if (reservation == null) return;

    _selectedClientId = reservation.clientId;
    _selectedDestinationId = reservation.destinationId;
    _status = reservation.status;
    _departureDateController.text = reservation.departureDate;
    _returnDateController.text = reservation.returnDate;
    _guestsController.text = reservation.numberOfGuests.toString();
    _notesController.text = reservation.notes ?? '';

    try {
      final ids = await context.read<ReservationController>().getServiceIdsByReservationId(reservation.id!);
      _selectedServiceIds
        ..clear()
        ..addAll(ids);
    } catch (_) {
      // ignore; editing can still work without preselected services
    }

    if (mounted) {
      setState(() {
        _totalPrice = reservation.totalPrice;
      });
      await _calculateTotalPrice();
    }
  }

  @override
  void dispose() {
    _departureDateController.dispose();
    _returnDateController.dispose();
    _guestsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
      _calculateTotalPrice();
    }
  }

  Future<void> _calculateTotalPrice() async {
    if (_selectedDestinationId != null && _guestsController.text.isNotEmpty) {
      final controller = context.read<ReservationController>();
      final price = await controller.calculateTotalPrice(
        destinationId: _selectedDestinationId!,
        numberOfGuests: int.tryParse(_guestsController.text) ?? 1,
        serviceIds: _selectedServiceIds.toList(),
      );
      setState(() {
        _totalPrice = price;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.reservation == null ? 'Create Reservation' : 'Edit Reservation'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<ReservationStatus>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'Status *',
                  border: OutlineInputBorder(),
                ),
                items: ReservationStatus.values
                    .map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text(s.displayName),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _status = value);
                },
              ),
              const SizedBox(height: 16),
              Consumer2<AuthController, ClientController>(
                builder: (context, authController, clientController, child) {
                  // For regular users, auto-select their own ID and hide the dropdown
                  if (!authController.isAdmin && widget.reservation == null) {
                    _selectedClientId = authController.currentUserId;
                  }
                  
                  if (!authController.isAdmin && widget.reservation == null) {
                    return TextFormField(
                      initialValue: authController.currentUser?.fullName ?? 'Current User',
                      decoration: const InputDecoration(
                        labelText: 'Client',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                    );
                  }
                  
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
                    onChanged: (value) {
                      setState(() => _selectedClientId = value);
                    },
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
                    onChanged: (value) {
                      setState(() {
                        _selectedDestinationId = value;
                        _calculateTotalPrice();
                      });
                    },
                    validator: (value) => value == null ? 'Please select a destination' : null,
                  );
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Departure Date *',
                controller: _departureDateController,
                readOnly: true,
                onTap: () => _selectDate(context, _departureDateController),
                validator: (value) => Validators.validateDate(value, 'Departure Date'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Return Date *',
                controller: _returnDateController,
                readOnly: true,
                onTap: () => _selectDate(context, _returnDateController),
                validator: (value) => Validators.validateDate(value, 'Return Date'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Number of Guests *',
                controller: _guestsController,
                keyboardType: TextInputType.number,
                validator: Validators.validateNumberOfGuests,
                onChanged: (_) => _calculateTotalPrice(),
              ),
              const SizedBox(height: 16),
              Consumer<AdditionalServiceController>(
                builder: (context, controller, child) {
                  return ExpansionTile(
                    title: const Text('Additional Services'),
                    children: controller.services.map((service) {
                      return CheckboxListTile(
                        title: Text('${service.name} - \$${service.price.toStringAsFixed(2)}'),
                        subtitle: service.description != null ? Text(service.description!) : null,
                        value: _selectedServiceIds.contains(service.id),
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedServiceIds.add(service.id!);
                            } else {
                              _selectedServiceIds.remove(service.id);
                            }
                            _calculateTotalPrice();
                          });
                        },
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Notes',
                controller: _notesController,
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Price:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(
                      '\$${_totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Consumer<ReservationController>(
                builder: (context, controller, child) {
                  return CustomButton(
                    text: widget.reservation == null ? 'Create Reservation' : 'Update Reservation',
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

  Future<void> _handleSubmit(BuildContext context, ReservationController controller) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClientId == null || _selectedDestinationId == null) return;

    final isEdit = widget.reservation != null;
    final notes = _notesController.text.trim().isEmpty ? null : _notesController.text.trim();

    final bool success;
    if (!isEdit) {
      success = await controller.createReservation(
        clientId: _selectedClientId!,
        destinationId: _selectedDestinationId!,
        departureDate: _departureDateController.text,
        returnDate: _returnDateController.text,
        numberOfGuests: int.parse(_guestsController.text),
        serviceIds: _selectedServiceIds.toList(),
        notes: notes,
      );
    } else {
      // Any edit sends reservation back to pending review
      _status = ReservationStatus.pending;
      final updatedReservation = widget.reservation!.copyWith(
        clientId: _selectedClientId!,
        destinationId: _selectedDestinationId!,
        departureDate: _departureDateController.text,
        returnDate: _returnDateController.text,
        numberOfGuests: int.parse(_guestsController.text),
        notes: notes,
        totalPrice: _totalPrice,
        status: _status,
      );

      final updated = await controller.updateReservation(updatedReservation);
      if (updated) {
        await controller.updateReservationServices(updatedReservation.id!, _selectedServiceIds.toList());
      }
      success = updated;
    }

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEdit ? 'Reservation updated successfully' : 'Reservation created successfully')),
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

