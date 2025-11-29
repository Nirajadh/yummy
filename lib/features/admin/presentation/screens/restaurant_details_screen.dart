import 'package:flutter/material.dart';
import 'package:yummy/core/services/restaurant_details_service.dart';

class RestaurantDetailsArgs {
  final bool allowSkip;
  final String? redirectRoute;

  const RestaurantDetailsArgs({
    this.allowSkip = false,
    this.redirectRoute,
  });
}

class RestaurantDetailsScreen extends StatefulWidget {
  final bool allowSkip;
  final String? redirectRoute;

  const RestaurantDetailsScreen({
    super.key,
    this.allowSkip = false,
    this.redirectRoute,
  });

  @override
  State<RestaurantDetailsScreen> createState() =>
      _RestaurantDetailsScreenState();
}

class _RestaurantDetailsScreenState extends State<RestaurantDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descriptionController = TextEditingController();
  final RestaurantDetailsService _service = RestaurantDetailsService();

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final details = await _service.getDetails();
    if (!mounted) return;
    _nameController.text = details.name;
    _addressController.text = details.address;
    _phoneController.text = details.phone;
    _descriptionController.text = details.description;
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() != true) return;
    setState(() => _saving = true);
    final details = RestaurantDetails(
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      phone: _phoneController.text.trim(),
      description: _descriptionController.text.trim(),
    );
    await _service.saveDetails(details);
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Restaurant details saved.')),
    );
    _goNext();
  }

  void _skip() {
    _goNext();
  }

  void _goNext() {
    final redirect = widget.redirectRoute;
    if (!mounted) return;
    if (redirect != null) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        redirect,
        (route) => false,
      );
      return;
    }
    if (Navigator.canPop(context)) {
      Navigator.pop(context, true);
    } else {
      Navigator.pushReplacementNamed(context, '/admin-dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Details'),
        actions: [
          if (widget.allowSkip)
            TextButton(
              onPressed: _skip,
              child: const Text('Skip'),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      'Add your restaurant profile so staff see the correct info across the app.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        hintText: 'Yummy Bistro',
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Restaurant name is required'
                              : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        hintText: '123 Main Street, City',
                      ),
                      maxLines: 2,
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Address is required'
                              : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                        hintText: '+1 555-0101',
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Phone is required'
                              : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Short description for staff and slips',
                      ),
                      maxLines: 3,
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Description is required'
                              : null,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton(
                        onPressed: _saving ? null : _save,
                        child: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Save and continue'),
                      ),
                    ),
                    if (widget.allowSkip) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton(
                          onPressed: _skip,
                          child: const Text("I'll do this later"),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}
