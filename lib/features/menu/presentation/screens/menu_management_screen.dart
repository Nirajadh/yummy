import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yummy/features/menu/presentation/bloc/menu/menu_bloc.dart';
import 'menu_item_form_screen.dart';

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  @override
  void initState() {
    super.initState();
    // Always attempt to load menus when the screen opens; if previous load
    // failed (e.g., missing restaurant id) this allows retry after setup.
    context.read<MenuBloc>().add(const MenuRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menu Management')),
      body: BlocBuilder<MenuBloc, MenuState>(
        builder: (context, state) {
          if (state.status == MenuStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == MenuStatus.failure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message ?? 'Failed to load menu'),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () =>
                        context.read<MenuBloc>().add(const MenuRequested()),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          final items = state.items;
          if (items.isEmpty) {
            return const Center(child: Text('No menu items yet.'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              context.read<MenuBloc>().add(const MenuRequested());
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final subtitle = StringBuffer()
                  ..write(
                    '${item.categoryName ?? (item.itemCategoryId != null ? 'Category ${item.itemCategoryId}' : 'Category N/A')} • ',
                  )
                  ..write('\$${item.price.toStringAsFixed(2)}');
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.deepOrange.withValues(alpha: .12),
                      child: const Icon(
                        Icons.restaurant,
                        color: Colors.deepOrange,
                      ),
                    ),
                    title: Text(item.name),
                    subtitle: Text(subtitle.toString()),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => Navigator.pushNamed(
                            context,
                            '/menu-edit',
                            arguments: MenuItemFormArgs(
                              id: item.id,
                              name: item.name,
                              categoryId: item.itemCategoryId,
                              price: item.price,
                              description: item.description,
                              imageUrl: item.imageUrl,
                            ),
                          ),
                        ),
                        state.deletingId == item.id
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => context.read<MenuBloc>().add(
                                  MenuItemDeleted(item.id ?? 0),
                                ),
                              ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'menu-fab',
        onPressed: () => Navigator.pushNamed(context, '/menu-add'),
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
    );
  }
}
