import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yummy/features/common/data/dummy_data.dart';
import 'package:yummy/features/menu/domain/entities/menu_item_entity.dart';
import 'package:yummy/features/menu/presentation/bloc/menu/menu_bloc.dart';

class MenuItemFormArgs {
  final String name;
  final String category;
  final double price;
  final String description;
  final String imageUrl;

  const MenuItemFormArgs({
    required this.name,
    this.category = 'Starters',
    this.price = 0,
    this.description = '',
    this.imageUrl = '',
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
  late final TextEditingController _imageController;
  late String _category;
  bool _loadedArgs = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _priceController = TextEditingController();
    _descriptionController = TextEditingController();
    _imageController = TextEditingController();
    _category = menuCategories[1];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loadedArgs) {
      final routeArgs = ModalRoute.of(context)?.settings.arguments;
      if (routeArgs is MenuItemFormArgs) {
        _nameController.text = routeArgs.name;
        if (routeArgs.price != 0) {
          _priceController.text = routeArgs.price.toString();
        }
        _descriptionController.text = routeArgs.description;
        _category = routeArgs.category;
        _imageController.text = routeArgs.imageUrl;
      }
      _loadedArgs = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState?.validate() != true) return;
    final item = MenuItemEntity(
      name: _nameController.text.trim(),
      category: _category,
      price: double.tryParse(_priceController.text) ?? 0,
      description: _descriptionController.text.trim(),
      imageUrl: _imageController.text.trim(),
    );
    context.read<MenuBloc>().add(MenuItemSaved(item));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.isEditing
              ? 'Menu item updated (UI only).'
              : 'Menu item added (UI only).',
        ),
      ),
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
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Menu Item' : 'Add Menu Item'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Item Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: menuCategories
                    .where((c) => c != 'All')
                    .map(
                      (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _category = value ?? _category),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                  hintText: 'https://example.com/photo.jpg',
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey.shade200,
                ),
                child: _imageController.text.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          _imageController.text,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 48,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.image, size: 48, color: Colors.grey),
                      ),
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
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                    ),
                    onPressed: _delete,
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
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
