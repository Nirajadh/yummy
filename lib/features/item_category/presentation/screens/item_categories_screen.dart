import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yummy/features/item_category/domain/entities/item_category_entity.dart';
import 'package:yummy/features/item_category/presentation/bloc/item_category_bloc.dart';

class ItemCategoriesScreen extends StatefulWidget {
  const ItemCategoriesScreen({super.key});

  @override
  State<ItemCategoriesScreen> createState() => _ItemCategoriesScreenState();
}

class _ItemCategoriesScreenState extends State<ItemCategoriesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ItemCategoryBloc>().add(const ItemCategoriesRequested());
  }

  void _openForm({ItemCategoryEntity? category}) {
    final controller = TextEditingController(text: category?.name ?? '');
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
            top: 18,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    category == null ? 'Add Category' : 'Edit Category',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(sheetContext),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Category name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: Text(category == null ? 'Create' : 'Update'),
                  onPressed: () {
                    final name = controller.text.trim();
                    if (name.isEmpty) return;
                    if (category == null) {
                      context.read<ItemCategoryBloc>().add(
                        ItemCategoryCreated(name),
                      );
                    } else {
                      context.read<ItemCategoryBloc>().add(
                        ItemCategoryUpdated(id: category.id, name: name),
                      );
                    }
                    Navigator.pop(sheetContext);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(ItemCategoryEntity category) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete category?'),
          content: Text(
            'This will remove "${category.name}". This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<ItemCategoryBloc>().add(
                  ItemCategoryDeleted(category.id),
                );
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ItemCategoryBloc, ItemCategoryState>(
      listener: (context, state) {
        if (state.message != null && state.message!.isNotEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message!)));
        }
      },
      builder: (context, state) {
        final theme = Theme.of(context);
        Widget body;
        if (state.status == ItemCategoryStatus.loading) {
          body = const Center(child: CircularProgressIndicator());
        } else if (state.status == ItemCategoryStatus.failure) {
          body = Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 42, color: Colors.red),
                const SizedBox(height: 8),
                Text(state.message ?? 'Failed to load categories'),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  onPressed: () => context.read<ItemCategoryBloc>().add(
                    const ItemCategoriesRequested(),
                  ),
                ),
              ],
            ),
          );
        } else {
          body = _CategoryList(
            categories: state.categories,
            deletingId: state.deletingId,
            onEdit: (category) => _openForm(category: category),
            onDelete: _confirmDelete,
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Item Categories'),
            actions: [
              IconButton(
                tooltip: 'Refresh',
                icon: const Icon(Icons.refresh),
                onPressed: () => context.read<ItemCategoryBloc>().add(
                  const ItemCategoriesRequested(),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openForm(),
            icon: const Icon(Icons.add),
            label: const Text('Add Category'),
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.06),
                  theme.scaffoldBackgroundColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: body,
          ),
        );
      },
    );
  }
}

class _CategoryList extends StatelessWidget {
  final List<ItemCategoryEntity> categories;
  final int? deletingId;
  final ValueChanged<ItemCategoryEntity> onEdit;
  final ValueChanged<ItemCategoryEntity> onDelete;

  const _CategoryList({
    required this.categories,
    required this.deletingId,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'No item categories yet. Add one to start organizing your menu.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final item = categories[index];
        final isDeleting = deletingId == item.id;
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.only(bottom: 14),
          child: ListTile(
            title: Text(
              item.name,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text('Restaurant ID: ${item.restaurantId}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => onEdit(item),
                ),
                isDeleting
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => onDelete(item),
                      ),
              ],
            ),
          ),
        );
      },
    );
  }
}
