import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yummy/core/services/restaurant_details_service.dart';
import 'package:yummy/features/restaurant/presentation/bloc/restaurant_bloc.dart';

class RestaurantDetailsArgs {
  final bool allowSkip;
  final String? redirectRoute;

  const RestaurantDetailsArgs({this.allowSkip = false, this.redirectRoute});
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
  int? _existingId;

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
    _existingId = details.id;
    _nameController.text = details.name;
    _addressController.text = details.address;
    _phoneController.text = details.phone;
    _descriptionController.text = details.description;
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() != true) return;
    setState(() => _saving = true);
    final name = _nameController.text.trim();
    final address = _addressController.text.trim();
    final phone = _phoneController.text.trim();
    final description = _descriptionController.text.trim();

    if (_existingId != null) {
      context.read<RestaurantBloc>().add(
        RestaurantUpdated(
          id: _existingId!,
          name: name,
          address: address,
          phone: phone,
          description: description,
        ),
      );
    } else {
      context.read<RestaurantBloc>().add(
        RestaurantSubmitted(
          name: name,
          address: address,
          phone: phone,
          description: description,
        ),
      );
    }
  }

  void _goNext() {
    final redirect = widget.redirectRoute;
    if (!mounted) return;
    if (redirect != null) {
      Navigator.pushNamedAndRemoveUntil(context, redirect, (route) => false);
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
    return BlocListener<RestaurantBloc, RestaurantState>(
      listener: (context, state) async {
        if (!mounted) return;
        if (state.status == RestaurantStatus.loading) {
          setState(() => _saving = true);
        } else {
          setState(() => _saving = false);
        }

        if (state.status == RestaurantStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }

        if (state.status == RestaurantStatus.success &&
            state.restaurant != null) {
          final wasExisting = _existingId != null;
          final details = RestaurantDetails(
            id: state.restaurant!.id,
            name: state.restaurant!.name,
            address: state.restaurant!.address,
            phone: state.restaurant!.phone,
            description: state.restaurant!.description ?? '',
          );
          await _service.saveDetails(details);
          _existingId = state.restaurant!.id;
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                wasExisting ? 'Restaurant updated.' : 'Restaurant created.',
              ),
            ),
          );
          _goNext();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xffFDF5F2),

        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      child: Column(
                        children: [
                          // Gradient hero header (inspired by Layout 5)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(18, 18, 18, 40),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xffF4511E), Color(0xffFF8A65)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(24),
                                topRight: Radius.circular(24),
                              ),
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Let\u2019s set up your restaurant',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Share a few details so your staff see the right info everywhere.',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Floating card with the real form
                          Transform.translate(
                            offset: const Offset(0, -24),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(
                                18,
                                24,
                                18,
                                24,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x1A000000),
                                    blurRadius: 24,
                                    offset: Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextFormField(
                                      controller: _nameController,
                                      decoration: const InputDecoration(
                                        labelText: 'Restaurant name',
                                        hintText: 'Yummy Bistro',
                                      ),
                                      textCapitalization:
                                          TextCapitalization.words,
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
                                        labelText: 'Short description',
                                        hintText:
                                            'Short description for staff and slips',
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
                                        style: FilledButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xffF4511E,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                        ),
                                        onPressed: _saving ? null : _save,
                                        child: _saving
                                            ? const SizedBox(
                                                width: 18,
                                                height: 18,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(Colors.white),
                                                ),
                                              )
                                            : Text(
                                                _existingId != null
                                                    ? 'Update and continue'
                                                    : 'Save and continue',
                                              ),
                                      ),
                                    ),
                                    if (widget.allowSkip) ...[
                                      const SizedBox(height: 8),
                                      Align(
                                        alignment: Alignment.center,
                                        child: TextButton(
                                          onPressed: _goNext,
                                          child: const Text(
                                            "I'll do this later",
                                            style: TextStyle(
                                              color: Color(0xffF4511E),
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }
}
