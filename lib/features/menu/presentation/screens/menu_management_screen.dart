import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yummy/features/menu/presentation/bloc/menu/menu_bloc.dart';
import 'menu_item_form_screen.dart';

class MenuManagementScreen extends StatelessWidget {
  const MenuManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menu Management')),
      body: BlocBuilder<MenuBloc, MenuState>(
        builder: (context, state) {
          if (state.status == MenuStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = state.items;
          if (items.isEmpty) {
            return const Center(child: Text('No menu items yet.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepOrange.withValues(alpha: .12),
                    child: const Icon(Icons.restaurant, color: Colors.deepOrange),
                  ),
                  title: Text(item.name),
                  subtitle: Text(
                    '${item.category} • \$${item.price.toStringAsFixed(2)}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => Navigator.pushNamed(
                      context,
                      '/menu-edit',
                      arguments: MenuItemFormArgs(
                        name: item.name,
                        category: item.category,
                        price: item.price,
                        description: item.description,
                        imageUrl: item.imageUrl,
                      ),
                    ),
                  ),
                ),
              );
            },
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
