import 'package:flutter/material.dart';

class GroupCreateScreen extends StatefulWidget {
  const GroupCreateScreen({super.key});

  @override
  State<GroupCreateScreen> createState() => _GroupCreateScreenState();
}

class _GroupCreateScreenState extends State<GroupCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _groupNameController = TextEditingController();
  final _peopleController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _notesController = TextEditingController();
  String? _type;

  @override
  void dispose() {
    _groupNameController.dispose();
    _peopleController.dispose();
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _createGroup() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Group created (UI only).')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Group')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _groupNameController,
                decoration: const InputDecoration(labelText: 'Group Name (optional)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _peopleController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Number of People (optional)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contactNameController,
                decoration: const InputDecoration(labelText: 'Contact Name (optional)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contactPhoneController,
                decoration: const InputDecoration(labelText: 'Contact Phone (optional)'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _type,
                items: const [
                  DropdownMenuItem(value: 'Birthday', child: Text('Birthday')),
                  DropdownMenuItem(value: 'Office', child: Text('Office')),
                  DropdownMenuItem(value: 'Family', child: Text('Family')),
                  DropdownMenuItem(value: 'Friends', child: Text('Friends')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                decoration: const InputDecoration(labelText: 'Type (optional)'),
                onChanged: (value) => setState(() => _type = value),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _createGroup,
                  child: const Text('Create Group'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
