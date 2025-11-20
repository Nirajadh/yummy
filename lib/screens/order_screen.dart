import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../models/bill_preview.dart';

class OrderScreenArgs {
  final String contextLabel;

  const OrderScreenArgs({this.contextLabel = 'Quick Bill'});
}

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  String _selectedCategory = 'All';
  final Map<String, _CartItem> _cart = {};
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

  List<MenuItemModel> get _filteredMenu {
    if (_selectedCategory == 'All') return dummyMenuItems;
    return dummyMenuItems
        .where((item) => item.category == _selectedCategory)
        .toList();
  }

  void _addToCart(MenuItemModel item) {
    setState(() {
      if (_cart.containsKey(item.name)) {
        _cart[item.name] = _cart[item.name]!.copyWith(
          quantity: _cart[item.name]!.quantity + 1,
        );
      } else {
        _cart[item.name] = _CartItem(item: item, quantity: 1);
      }
    });
  }

  void _changeQuantity(String key, int delta) {
    setState(() {
      final cartItem = _cart[key];
      if (cartItem == null) return;
      final newQty = cartItem.quantity + delta;
      if (newQty <= 0) {
        _cart.remove(key);
      } else {
        _cart[key] = cartItem.copyWith(quantity: newQty);
      }
    });
  }

  double get _subtotal => _cart.values.fold(
    0,
    (total, item) => total + item.item.price * item.quantity,
  );

  BillPreviewArgs _buildBillPreviewArgs({
    required double tax,
    required double service,
    required double total,
  }) {
    final items = _cart.values
        .map(
          (cartItem) => BillLineItem(
            name: cartItem.item.name,
            quantity: cartItem.quantity,
            price: cartItem.item.price,
          ),
        )
        .toList();

    return BillPreviewArgs(
      orderLabel: _args.contextLabel,
      items: items,
      subtotal: _subtotal,
      tax: tax,
      serviceCharge: service,
      grandTotal: total,
    );
  }

  void _showAction(String action) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(action)));
  }

  @override
  Widget build(BuildContext context) {
    final tax = _subtotal * 0.1;
    final service = _subtotal * 0.05;
    final total = _subtotal + tax + service;

    return Scaffold(
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
                    final category = menuCategories[index];
                    final selected = _selectedCategory == category;
                    return ChoiceChip(
                      label: Text(category),
                      selected: selected,
                      onSelected: (_) =>
                          setState(() => _selectedCategory = category),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemCount: menuCategories.length,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.9,
                        ),
                    itemCount: _filteredMenu.length,
                    itemBuilder: (context, index) {
                      final item = _filteredMenu[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.fastfood,
                                    size: 32,
                                    color: Colors.grey,
                                  ),
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
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.tonal(
                                  onPressed: () => _addToCart(item),
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
          _buildCartSheet(tax: tax, service: service, total: total),
        ],
      ),
    );
  }

  Widget _buildCartSheet({
    required double tax,
    required double service,
    required double total,
  }) {
    final entries = _cart.entries.toList();
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
          color: colorScheme.surfaceVariant.withOpacity(0.95),
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
                              backgroundColor: accent.withOpacity(0.12),
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
                                  color: accent.withOpacity(0.12),
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
                            color: colorScheme.surface.withOpacity(0.7),
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
                                    onPressed: () =>
                                        _changeQuantity(item.item.name, -1),
                                  ),
                                  Text('${item.quantity}'),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed: () =>
                                        _changeQuantity(item.item.name, 1),
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
                          color: colorScheme.surfaceVariant.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            _TotalRow(label: 'Subtotal', value: _subtotal),
                            _TotalRow(label: 'Tax (10%)', value: tax),
                            _TotalRow(label: 'Service (5%)', value: service),
                            const SizedBox(height: 4),
                            _TotalRow(
                              label: 'Grand Total',
                              value: total,
                              emphasize: true,
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 10,
                              runSpacing: 12,
                              children: [
                                FilledButton(
                                  onPressed: () =>
                                      _showAction('Sent to kitchen'),
                                  child: const Text('Send to Kitchen'),
                                ),
                                FilledButton.tonal(
                                  onPressed: () => _showAction('KOT printed'),
                                  child: const Text('Print KOT'),
                                ),
                                FilledButton.tonal(
                                  onPressed: () {
                                    if (_cart.isEmpty) {
                                      _showAction('Add items before printing');
                                      return;
                                    }
                                    Navigator.pushNamed(
                                      context,
                                      '/bill-preview',
                                      arguments: _buildBillPreviewArgs(
                                        tax: tax,
                                        service: service,
                                        total: total,
                                      ),
                                    );
                                  },
                                  child: const Text('Print Bill'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    if (_cart.isEmpty) {
                                      _showAction('Add items before checkout');
                                      return;
                                    }
                                    Navigator.pushNamed(
                                      context,
                                      '/bill-preview',
                                      arguments: _buildBillPreviewArgs(
                                        tax: tax,
                                        service: service,
                                        total: total,
                                      ),
                                    );
                                  },
                                  child: const Text('Payment'),
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

class _CartItem {
  final MenuItemModel item;
  final int quantity;

  const _CartItem({required this.item, required this.quantity});

  _CartItem copyWith({MenuItemModel? item, int? quantity}) {
    return _CartItem(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
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
