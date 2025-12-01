import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:yummy/features/item_category/presentation/bloc/item_category_bloc.dart';
import 'package:yummy/features/menu/presentation/bloc/menu_item_form_bloc.dart';
import 'package:yummy/features/menu/presentation/bloc/menu/menu_bloc.dart';

class MenuItemFormArgs {
  final int? id;
  final String name;
  final int? categoryId;
  final double price;
  final String description;
  final String imageUrl;

  const MenuItemFormArgs({
    this.id,
    required this.name,
    this.categoryId,
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
  String? _imagePath;
  bool _loadedArgs = false;
  bool _requestedCategories = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _priceController = TextEditingController();
    _descriptionController = TextEditingController();
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
        context.read<MenuItemFormBloc>().add(
          MenuItemFormCategoryUpdated(routeArgs.categoryId?.toString()),
        );
        _imagePath = routeArgs.imageUrl.isNotEmpty ? routeArgs.imageUrl : null;
      }
      _loadedArgs = true;
    }

    if (!_requestedCategories) {
      _requestedCategories = true;
      context.read<ItemCategoryBloc>().add(const ItemCategoriesRequested());
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save(String fallbackCategoryId) {
    if (_formKey.currentState?.validate() != true) return;
    final args =
        ModalRoute.of(context)?.settings.arguments as MenuItemFormArgs?;
    final selectedCategoryId =
        context.read<MenuItemFormBloc>().state.selectedCategory ??
        fallbackCategoryId;
    final categories = context.read<ItemCategoryBloc>().state.categories;
    final selectedCategoryName = categories
        .firstWhere((c) => c.id.toString() == selectedCategoryId)
        .name;
    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text) ?? 0;
    final description = _descriptionController.text.trim();
    final image = _imagePath?.trim() ?? '';
    final imagePathForUpload =
        image.isNotEmpty && !image.toLowerCase().startsWith('http')
        ? image
        : null;

    if (widget.isEditing && args?.id != null) {
      context.read<MenuBloc>().add(
        MenuItemUpdated(
          id: args!.id!,
          name: name,
          price: price,
          itemCategoryId: int.tryParse(selectedCategoryId),
          categoryName: selectedCategoryName,
          description: description.isEmpty ? null : description,
          imagePath: imagePathForUpload,
        ),
      );
    } else {
      context.read<MenuBloc>().add(
        MenuItemCreated(
          name: name,
          price: price,
          itemCategoryId: int.tryParse(selectedCategoryId) ?? 0,
          categoryName: selectedCategoryName,
          description: description.isEmpty ? null : description,
          imagePath: imagePathForUpload,
        ),
      );
    }
    Navigator.pop(context);
  }

  void _delete() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Menu item deleted (UI only).')),
    );
    Navigator.pop(context);
  }

  Future<void> _pickImage(ImageSource source) async {
    final granted = await _ensurePermission(
      source == ImageSource.camera ? Permission.camera : Permission.photos,
    );
    if (!granted) return;

    try {
      final result = await ImagePicker().pickImage(source: source);
      if (result != null && result.path.isNotEmpty) {
        final lower = result.path.toLowerCase();
        if (!lower.endsWith('.jpg') && !lower.endsWith('.jpeg')) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Only JPEG images are allowed')),
          );
          return;
        }
        setState(() => _imagePath = result.path);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No file selected')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to open picker: $e')));
    }
  }

  Future<bool> _ensurePermission(Permission permission) async {
    var status = await permission.status;
    if (status.isGranted) return true;
    status = await permission.request();
    if (status.isGranted) return true;
    if (!mounted) return false;
    final permanentlyDenied = status.isPermanentlyDenied;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission needed'),
        content: Text(
          permanentlyDenied
              ? 'Please grant access in Settings to choose images.'
              : 'Please allow access to proceed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Not now'),
          ),
          if (permanentlyDenied)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                openAppSettings();
              },
              child: const Text('Open Settings'),
            )
          else
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await permission.request();
              },
              child: const Text('Allow'),
            ),
        ],
      ),
    );
    return false;
  }

  void _showImageSourceSheet() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Gallery (JPEG)'),
              subtitle: const Text('Pick from device storage'),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Camera (JPEG)'),
              subtitle: const Text('Capture a new photo'),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Menu Item' : 'Add Menu Item'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: BlocBuilder<ItemCategoryBloc, ItemCategoryState>(
          builder: (context, categoryState) {
            final fallbackCategoryId = categoryState.categories.isNotEmpty
                ? categoryState.categories.first.id.toString()
                : '0';
            final currentValue =
                context.watch<MenuItemFormBloc>().state.selectedCategory ??
                (categoryState.categories.isNotEmpty
                    ? categoryState.categories.first.id.toString()
                    : null);

            return Form(
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
                    initialValue: currentValue,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: categoryState.categories
                        .map(
                          (cat) => DropdownMenuItem(
                            value: cat.id.toString(),
                            child: Text(cat.name),
                          ),
                        )
                        .toList(),
                    hint: const Text('Select category'),
                    onChanged: (value) => context.read<MenuItemFormBloc>().add(
                      MenuItemFormCategoryUpdated(value),
                    ),
                  ),
                  if (categoryState.status == ItemCategoryStatus.loading)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: LinearProgressIndicator(minHeight: 2),
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
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Image',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          (_imagePath?.isNotEmpty ?? false)
                              ? _imagePath!
                              : 'No file selected',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: (_imagePath?.isNotEmpty ?? false)
                                ? Colors.black87
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: _showImageSourceSheet,
                        icon: const Icon(Icons.folder_open),
                        label: const Text('Choose'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.grey.shade200,
                    ),
                    child: (_imagePath?.isNotEmpty ?? false)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: _imagePath!.startsWith('http')
                                ? Image.network(
                                    _imagePath!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        size: 48,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )
                                : Image.file(
                                    File(_imagePath!),
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
                            child: Icon(
                              Icons.image,
                              size: 48,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: () => _save(fallbackCategoryId),
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
            );
          },
        ),
      ),
    );
  }
}
