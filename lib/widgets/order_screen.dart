import 'package:flutter/material.dart';
import '../models/bill_preview.dart';

class OrderScreenArgs {
  final bool isTableOrder;
  final bool isGroupOrder;
  final bool isPickupOrder;
  final bool isQuickBilling;
  final String? sourceId;

  const OrderScreenArgs({
    this.isTableOrder = false,
    this.isGroupOrder = false,
    this.isPickupOrder = false,
    this.isQuickBilling = false,
    this.sourceId,
  });
}

class SharedOrderScreen extends StatefulWidget {
  final OrderScreenArgs args;

  const SharedOrderScreen({super.key, required this.args});

  @override
  State<SharedOrderScreen> createState() => _SharedOrderScreenState();
}

class _MenuItem {
  final String id;
  final String name;
  final double price;
  final String category;

  const _MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
  });
}

class _SharedOrderScreenState extends State<SharedOrderScreen> {
  static const _categories = ['Starters', 'Main Course', 'Drinks', 'Desserts'];
  final List<_MenuItem> _menuItems = const [
    _MenuItem(id: '1', name: 'Chicken Momo', price: 250, category: 'Starters'),
    _MenuItem(id: '2', name: 'Paneer Tikka', price: 300, category: 'Starters'),
    _MenuItem(
      id: '3',
      name: 'Veg Chowmein',
      price: 220,
      category: 'Main Course',
    ),
    _MenuItem(
      id: '4',
      name: 'Chicken Biryani',
      price: 350,
      category: 'Main Course',
    ),
    _MenuItem(id: '5', name: 'Cold Coffee', price: 180, category: 'Drinks'),
    _MenuItem(id: '6', name: 'Lemonade', price: 120, category: 'Drinks'),
    _MenuItem(
      id: '7',
      name: 'Chocolate Brownie',
      price: 200,
      category: 'Desserts',
    ),
  ];

  String _selectedCategory = _categories.first;
  final Map<String, int> _cart = {};

  List<_MenuItem> get _filteredMenu =>
      _menuItems.where((item) => item.category == _selectedCategory).toList();

  double get _subtotal => _cart.entries.fold(0, (total, entry) {
    final item = _menuItems.firstWhere((element) => element.id == entry.key);
    return total + item.price * entry.value;
  });

  double get _tax => _subtotal * 0.13;
  double get _serviceCharge => _subtotal * 0.1;
  double get _grandTotal => _subtotal + _tax + _serviceCharge;

  void _addToCart(_MenuItem item) {
    setState(() {
      _cart.update(item.id, (value) => value + 1, ifAbsent: () => 1);
    });
  }

  void _updateQty(String id, int delta) {
    setState(() {
      final current = _cart[id] ?? 0;
      final next = current + delta;
      if (next <= 0) {
        _cart.remove(id);
      } else {
        _cart[id] = next;
      }
    });
  }

  void _showActionSnackBar(String label) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label (UI only)')));
  }

  BillPreviewArgs _buildBillPreviewArgs(String label) {
    final items = _cart.entries.map((entry) {
      final item = _menuItems.firstWhere((element) => element.id == entry.key);
      return BillLineItem(
        name: item.name,
        quantity: entry.value,
        price: item.price,
      );
    }).toList();

    return BillPreviewArgs(
      orderLabel: label,
      items: items,
      subtotal: _subtotal,
      tax: _tax,
      serviceCharge: _serviceCharge,
      grandTotal: _grandTotal,
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderLabel = widget.args.isTableOrder
        ? 'Table ${widget.args.sourceId ?? ''}'
        : widget.args.isGroupOrder
        ? 'Group ${widget.args.sourceId ?? ''}'
        : widget.args.isPickupOrder
        ? 'Pickup ${widget.args.sourceId ?? ''}'
        : widget.args.isQuickBilling
        ? 'Quick Billing'
        : 'Order';

    return Scaffold(
      appBar: AppBar(title: Text('Order Screen · $orderLabel')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 900) {
            return _buildColumnLayout(orderLabel);
          }
          return Row(
            children: [
              SizedBox(width: 200, child: _buildCategoryList()),
              Expanded(flex: 2, child: _buildMenuGrid()),
              SizedBox(width: 320, child: _buildCart(orderLabel)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildColumnLayout(String orderLabel) {
    return Column(
      children: [
        SizedBox(height: 120, child: _buildCategoryList()),
        Expanded(child: _buildMenuGrid()),
        SizedBox(height: 320, child: _buildCart(orderLabel)),
      ],
    );
  }

  Widget _buildCategoryList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        final category = _categories[index];
        final isSelected = category == _selectedCategory;
        return ChoiceChip(
          label: Text(category),
          selected: isSelected,
          onSelected: (_) => setState(() => _selectedCategory = category),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemCount: _categories.length,
    );
  }

  Widget _buildMenuGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: _filteredMenu.length,
      itemBuilder: (context, index) {
        final item = _filteredMenu[index];
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: () => _addToCart(item),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.image, size: 48),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text('Rs ${item.price.toStringAsFixed(0)}'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCart(String orderLabel) {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cart', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Expanded(
              child: _cart.isEmpty
                  ? const Center(child: Text('No items yet'))
                  : ListView.separated(
                      itemCount: _cart.length,
                      itemBuilder: (context, index) {
                        final entry = _cart.entries.elementAt(index);
                        final item = _menuItems.firstWhere(
                          (element) => element.id == entry.key,
                        );
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text(item.name)),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                      ),
                                      onPressed: () => _updateQty(item.id, -1),
                                    ),
                                    Text(entry.value.toString()),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                      ),
                                      onPressed: () => _updateQty(item.id, 1),
                                    ),
                                  ],
                                ),
                                Text(
                                  'Rs ${(item.price * entry.value).toStringAsFixed(0)}',
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                      separatorBuilder: (_, __) => const Divider(),
                    ),
            ),
            const Divider(height: 32),
            _buildSummaryRow('Subtotal', _subtotal),
            _buildSummaryRow('Tax (13%)', _tax),
            _buildSummaryRow('Service (10%)', _serviceCharge),
            const Divider(height: 32),
            _buildSummaryRow('Grand Total', _grandTotal, isBold: true),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: () => _showActionSnackBar('Sent to kitchen'),
                  child: const Text('Send to Kitchen'),
                ),
                OutlinedButton(
                  onPressed: () => _showActionSnackBar('Print KOT'),
                  child: const Text('Print KOT'),
                ),
                OutlinedButton(
                  onPressed: () {
                    if (_cart.isEmpty) {
                      _showActionSnackBar('Add items before printing');
                      return;
                    }
                    Navigator.pushNamed(
                      context,
                      '/bill-preview',
                      arguments: _buildBillPreviewArgs(orderLabel),
                    );
                  },
                  child: const Text('Print Bill'),
                ),
                FilledButton.tonal(
                  onPressed: () => _showActionSnackBar('Payment flow'),
                  child: const Text('Payment'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isBold = false}) {
    final style = isBold
        ? Theme.of(context).textTheme.titleMedium
        : Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text('Rs ${amount.toStringAsFixed(0)}', style: style),
        ],
      ),
    );
  }
}
