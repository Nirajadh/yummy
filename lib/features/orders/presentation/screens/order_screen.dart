import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:yummy/features/menu/domain/entities/menu_item_entity.dart';
import 'package:yummy/features/menu/presentation/bloc/menu/menu_bloc.dart';
import 'package:yummy/features/orders/domain/entities/bill_preview.dart';
import 'package:yummy/features/orders/presentation/bloc/order_cart/order_cart_cubit.dart';

class OrderScreenArgs {
  final String contextLabel;

  const OrderScreenArgs({this.contextLabel = 'Menu'});
}

Widget _placeholderIcon() {
  return Container(
    color: Colors.grey.shade200,
    child: const Center(
      child: Icon(Icons.fastfood, size: 32, color: Colors.grey),
    ),
  );
}

class OrderScreenResult {
  final bool sentToKitchen;
  final double subtotal;
  final List<BillLineItem> items;

  const OrderScreenResult({
    required this.sentToKitchen,
    required this.subtotal,
    required this.items,
  });
}

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  OrderScreenArgs _args = const OrderScreenArgs();
  bool _loadedArgs = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loadedArgs) {
      final routeArgs = ModalRoute.of(context)?.settings.arguments;
      if (routeArgs is OrderScreenArgs) {
        _args = routeArgs;
      }
      _loadedArgs = true;
    }
  }

  List<MenuItemEntity> _filteredMenu(
    List<MenuItemEntity> source,
    String selectedCategory,
  ) {
    if (selectedCategory == 'All') return source;
    return source.where((item) => item.category == selectedCategory).toList();
  }

  List<String> _categoriesFromMenu(List<MenuItemEntity> items) {
    final categories = <String>{};
    for (final item in items) {
      categories.add(item.category);
    }
    final sorted = categories.toList()..sort();
    return ['All', ...sorted];
  }

  List<BillLineItem> _billLinesFromCart(OrderCartState cartState) {
    return cartState.items.values
        .map(
          (cartItem) => BillLineItem(
            name: cartItem.item.name,
            quantity: cartItem.quantity,
            price: cartItem.item.price,
          ),
        )
        .toList();
  }

  BillPreviewArgs _buildBillPreviewArgs(OrderCartState cartState) {
    final items = _billLinesFromCart(cartState);

    return BillPreviewArgs(
      orderLabel: _args.contextLabel,
      items: items,
      subtotal: cartState.subtotal,
      tax: 0,
      serviceCharge: 0,
      grandTotal: cartState.subtotal,
      allowMultiplePayments: true,
    );
  }

  void _showAction(String action) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(action)));
  }

  @override
  Widget build(BuildContext context) {
    final menuState = context.watch<MenuBloc>().state;
    final cartState = context.watch<OrderCartCubit>().state;

    if (menuState.status == MenuStatus.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (menuState.status == MenuStatus.failure) {
      return const Scaffold(
        body: Center(child: Text('Failed to load menu items')),
      );
    }

    final categories = _categoriesFromMenu(menuState.items);
    final filteredMenu = _filteredMenu(
      menuState.items,
      cartState.selectedCategory,
    );
    final total = cartState.subtotal;

    return WillPopScope(
      onWillPop: () async {
        final cartState = context.read<OrderCartCubit>().state;
        Navigator.pop(
          context,
          OrderScreenResult(
            sentToKitchen: cartState.sentToKitchen,
            subtotal: cartState.subtotal,
            items: _billLinesFromCart(cartState),
          ),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(title: Text(_args.contextLabel)),
        body: Stack(
          children: [
            Column(
              children: [
                SizedBox(
                  height: 60,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final selected = cartState.selectedCategory == category;
                      return ChoiceChip(
                        label: Text(category),
                        selected: selected,
                        onSelected: (_) => context
                            .read<OrderCartCubit>()
                            .selectCategory(category),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemCount: categories.length,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: filteredMenu.isEmpty
                        ? const Center(child: Text('No menu items available.'))
                        : GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 0.9,
                                ),
                            itemCount: filteredMenu.length,
                            itemBuilder: (context, index) {
                              final item = filteredMenu[index];
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: item.imageUrl.isNotEmpty
                                              ? Image.network(
                                                  item.imageUrl,
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  errorBuilder: (_, __, ___) =>
                                                      _placeholderIcon(),
                                                )
                                              : _placeholderIcon(),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        item.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        '\$${item.price.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        width: double.infinity,
                                        child: FilledButton.tonal(
                                          onPressed: () => context
                                              .read<OrderCartCubit>()
                                              .addItem(item),
                                          child: const Text('+ Add'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
            _buildCartSheet(total: total, cartState: cartState),
          ],
        ),
      ),
    );
  }

  Widget _buildCartSheet({
    required double total,
    required OrderCartState cartState,
  }) {
    final entries = cartState.items.entries.toList();
    final hasItems = entries.isNotEmpty;
    final itemCount = entries.length;

    double minSize = hasItems ? 0.18 : 0.10;
    double initialSize = hasItems
        ? 0.22 + itemCount * 0.08
        : 0.18; // grow with items
    double maxSize = hasItems ? 0.32 + itemCount * 0.12 : 0.2; // cap when empty

    initialSize = (initialSize.clamp(minSize + 0.02, 0.65));
    maxSize = (maxSize.clamp(initialSize + 0.02, 0.9));
    minSize = (minSize.clamp(0.12, initialSize));

    return DraggableScrollableSheet(
      initialChildSize: initialSize,
      minChildSize: minSize,
      maxChildSize: hasItems ? maxSize : 0.2,
      builder: (context, scrollController) {
        final colorScheme = Theme.of(context).colorScheme;
        final accent = colorScheme.primary;
        return Material(
          elevation: 12,
          color: colorScheme.surfaceVariant.withValues(alpha: 0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: CustomScrollView(
                controller: scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: accent.withValues(alpha: 0.12),
                              child: Icon(
                                Icons.shopping_cart_outlined,
                                color: accent,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Cart',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (hasItems)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: accent.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${entries.length} item${entries.length == 1 ? '' : 's'}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: accent,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (!hasItems) const SizedBox(height: 10),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                  if (!hasItems)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: Text(
                            'No items added yet.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      ),
                    )
                  else ...[
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final entry = entries[index];
                        final item = entry.value;
                        return Container(
                          margin: EdgeInsets.only(
                            bottom: index == entries.length - 1 ? 0 : 10,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.surface.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.item.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '\$${item.item.price.toStringAsFixed(2)} each',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                    ),
                                    onPressed: () => context
                                        .read<OrderCartCubit>()
                                        .changeQuantity(item.item.name, -1),
                                  ),
                                  Text('${item.quantity}'),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed: () => context
                                        .read<OrderCartCubit>()
                                        .changeQuantity(item.item.name, 1),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '\$${(item.item.price * item.quantity).toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: accent,
                                ),
                              ),
                            ],
                          ),
                        );
                      }, childCount: entries.length),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 12)),
                    SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceVariant.withValues(
                            alpha: 0.6,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            _TotalRow(
                              label: 'Subtotal',
                              value: cartState.subtotal,
                            ),
                            _TotalRow(
                              label: 'Grand Total',
                              value: total,
                              emphasize: true,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  cartState.sentToKitchen
                                      ? Icons.check_circle
                                      : Icons.pending_outlined,
                                  color: cartState.sentToKitchen
                                      ? Colors.green
                                      : colorScheme.outline,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  cartState.sentToKitchen
                                      ? 'Sent to kitchen'
                                      : 'Pending send to kitchen',
                                  style: TextStyle(
                                    color: cartState.sentToKitchen
                                        ? Colors.green
                                        : colorScheme.outline,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _ActionCardButton(
                                    icon: Icons.local_fire_department_outlined,
                                    title: 'Send to Kitchen',
                                    subtitle: 'Push order to the line',
                                    gradient: [
                                      accent.withValues(alpha: 0.95),
                                      accent,
                                    ],
                                    onTap: hasItems
                                        ? () {
                                            context
                                                .read<OrderCartCubit>()
                                                .markSentToKitchen();
                                            _showAction('Sent to kitchen');
                                          }
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _ActionCardButton(
                                    icon: Icons.arrow_forward_rounded,
                                    title: 'Proceed to Checkout',
                                    subtitle: 'Review bill & payments',
                                    gradient: [
                                      colorScheme.secondary.withValues(
                                        alpha: 0.95,
                                      ),
                                      colorScheme.secondary,
                                    ],
                                    onTap: hasItems
                                        ? () {
                                            if (!cartState.sentToKitchen) {
                                              _showAction(
                                                'Send to kitchen before checkout',
                                              );
                                              return;
                                            }
                                            Navigator.pushNamed(
                                              context,
                                              '/bill-preview',
                                              arguments: _buildBillPreviewArgs(
                                                cartState,
                                              ),
                                            );
                                          }
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ActionCardButton extends StatelessWidget {
  final VoidCallback? onTap;
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;

  const _ActionCardButton({
    required this.onTap,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;
    final scheme = Theme.of(context).colorScheme;
    final colors = isDisabled
        ? [scheme.surfaceVariant, scheme.surfaceVariant]
        : gradient;

    return AnimatedOpacity(
      opacity: isDisabled ? 0.5 : 1,
      duration: const Duration(milliseconds: 200),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(14),
          boxShadow: isDisabled
              ? null
              : [
                  BoxShadow(
                    color: colors.last.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: Colors.white, size: 20),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
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

class _TotalRow extends StatelessWidget {
  final String label;
  final double value;
  final bool emphasize;

  const _TotalRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = emphasize
        ? const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
        : const TextStyle(color: Colors.grey);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text('\$${value.toStringAsFixed(2)}', style: style),
        ],
      ),
    );
  }
}
