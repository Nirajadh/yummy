import 'package:flutter/material.dart';

import '../data/dummy_data.dart';

class MenuItemFormArgs {
  final String name;
  final String category;
  final double price;
  final String description;

  const MenuItemFormArgs({
    required this.name,
    this.category = 'Starters',
    this.price = 0,
    this.description = '',
  });
}

class MenuItemFormScreen extends StatefulWidget {
  final bool isEditing;

  const MenuItemFormScreen({super.key, required this.isEditing});

  @override
  State<MenuItemFormScreen> createState() => _MenuItemFormScreenState();
}

class _MenuItemFormScreenState extends State<MenuItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;
  late String _category;
  bool _loadedArgs = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _priceController = TextEditingController();
    _descriptionController = TextEditingController();
    _category = menuCategories[1];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loadedArgs) {
      final routeArgs = ModalRoute.of(context)?.settings.arguments;
      if (routeArgs is MenuItemFormArgs) {
        _nameController.text = routeArgs.name;
        if (routeArgs.price != 0) _priceController.text = routeArgs.price.toString();
        _descriptionController.text = routeArgs.description;
        _category = routeArgs.category;
      }
      _loadedArgs = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState?.validate() != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(widget.isEditing ? 'Menu item updated (UI only).' : 'Menu item added (UI only).')),
    );
    Navigator.pop(context);
  }

  void _delete() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Menu item deleted (UI only).')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.isEditing ? 'Edit Menu Item' : 'Add Menu Item')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Item Name'),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: menuCategories
                    .where((c) => c != 'All')
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (value) => setState(() => _category = value ?? _category),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price'),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 16),
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey.shade200,
                ),
                child: const Center(child: Icon(Icons.image, size: 48, color: Colors.grey)),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _save,
                  child: const Text('Save'),
                ),
              ),
              if (widget.isEditing) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.tonal(
                    style: FilledButton.styleFrom(backgroundColor: Colors.red.shade50),
                    onPressed: _delete,
                    child: const Text('Delete', style: TextStyle(color: Colors.red)),
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
