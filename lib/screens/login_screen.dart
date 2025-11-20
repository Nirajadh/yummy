import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _role;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true || _role == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter credentials and role.')),
      );
      return;
    }

    switch (_role) {
      case 'Admin':
        Navigator.pushReplacementNamed(context, '/admin-dashboard');
        break;
      case 'Staff':
        Navigator.pushReplacementNamed(context, '/staff-dashboard');
        break;
      case 'Kitchen':
        Navigator.pushReplacementNamed(context, '/kitchen-dashboard');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    children: const [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.deepOrange,
                        child: Icon(Icons.restaurant, color: Colors.white, size: 40),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'MyRestro',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text('Smart POS for modern restaurants'),
                    ],
                  ),
                  const SizedBox(height: 32),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Select Role'),
                    value: _role,
                    items: const [
                      DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                      DropdownMenuItem(value: 'Staff', child: Text('Staff')),
                      DropdownMenuItem(value: 'Kitchen', child: Text('Kitchen')),
                    ],
                    onChanged: (value) => setState(() => _role = value),
                    validator: (value) => value == null ? 'Choose a role' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(labelText: 'Username'),
                    validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      onPressed: _submit,
                      child: const Text('Login'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
