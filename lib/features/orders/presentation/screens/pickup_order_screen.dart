import 'package:flutter/material.dart';
import 'package:yummy/features/orders/domain/entities/order_enums.dart';

import 'order_screen.dart';

class PickupOrderScreen extends StatefulWidget {
  const PickupOrderScreen({super.key});

  @override
  State<PickupOrderScreen> createState() => _PickupOrderScreenState();
}

class _PickupOrderScreenState extends State<PickupOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _timeController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  void _startOrder() {
    if (_formKey.currentState?.validate() != true) return;
    Navigator.pushNamed(
      context,
      '/order-screen',
      arguments: OrderScreenArgs(
        contextLabel: 'Pickup: ${_nameController.text}',
        channel: OrderChannel.pickup,
        customerName: _nameController.text,
        customerPhone: _phoneController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pickup Order')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Customer Name'),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _timeController,
                decoration: const InputDecoration(labelText: 'Pickup Time'),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _startOrder,
                  child: const Text('Start Adding Items'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
