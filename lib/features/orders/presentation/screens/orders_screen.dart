import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yummy/features/orders/domain/entities/active_order_entity.dart';
import 'package:yummy/features/orders/domain/entities/order_enums.dart';
import 'package:yummy/features/orders/presentation/bloc/orders/orders_bloc.dart';
import 'package:yummy/features/orders/presentation/screens/group_order_screen.dart';
import 'package:yummy/features/orders/presentation/screens/order_screen.dart';
import 'package:yummy/features/tables/presentation/navigation/table_order_args.dart';
import 'package:yummy/features/tables/presentation/navigation/tables_screen_args.dart';

class OrdersScreen extends StatefulWidget {
  final bool allowMenuManagement;
  final bool allowTableManagement;
  final String dashboardRoute;

  const OrdersScreen({
    super.key,
    this.allowMenuManagement = true,
    this.allowTableManagement = true,
    this.dashboardRoute = '/admin-dashboard',
  });

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  static const _filters = ['All', 'Table', 'Group', 'Pickup', 'Quick Billing'];
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    // Kick off initial fetch after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchOrders());
  }

  Future<void> _fetchOrders() async {
    final bloc = context.read<OrdersBloc>();
    bloc.add(
      OrdersRequested(
        filter: _selectedFilter == 'All' ? null : _selectedFilter,
      ),
    );
    // Wait for the next non-loading state so pull-to-refresh completes.
    await bloc.stream.firstWhere(
      (state) => state.status != OrdersStatus.loading,
    );
  }

  void _goToDashboard() {
    final target = (widget.dashboardRoute.isNotEmpty
        ? widget.dashboardRoute
        : '/admin-dashboard');
    Navigator.pushNamedAndRemoveUntil(context, target, (route) => false);
  }

  List<ActiveOrderEntity> _filteredOrders(List<ActiveOrderEntity> source) {
    if (_selectedFilter == 'All') return List.of(source);
    return source.where((order) => order.type == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final ordersState = context.watch<OrdersBloc>().state;
    final allOrders = ordersState.orders;
    final filteredOrders = _filteredOrders(allOrders);
    final theme = Theme.of(context);
    final pendingPayments = allOrders
        .where((order) => order.status.toLowerCase().contains('pending'))
        .length;
    final totalValue = allOrders.fold<double>(
      0,
      (total, order) => total + order.amount,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goToDashboard,
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'orders-fab',
        onPressed: _showCreateOrderSheet,
        icon: const Icon(Icons.add),
        label: const Text('Create Order'),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchOrders,
        child: ListView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            _OrdersSummary(
              activeCount: allOrders.length,
              pendingBilling: pendingPayments,
              totalValue: totalValue,
            ),
            const SizedBox(height: 24),
            Text('Filter by type', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters
                    .map(
                      (filter) => Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: ChoiceChip(
                          label: Text(filter),
                          selected: _selectedFilter == filter,
                          onSelected: (_) {
                            setState(() => _selectedFilter = filter);
                            _fetchOrders();
                          },
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            if (ordersState.status == OrdersStatus.loading)
              const Center(child: CircularProgressIndicator())
            else if (ordersState.status == OrdersStatus.failure)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Failed to load orders.'),
                ),
              )
            else if (filteredOrders.isEmpty)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(Icons.inbox_outlined, size: 32, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('No active orders in this segment.'),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredOrders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final order = filteredOrders[index];
                  return _OrderCard(
                    order: order,
                    onTap: () => _openOrder(order),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _openOrder(ActiveOrderEntity order) async {
    final type = order.type.toLowerCase();
    if (type == 'table') {
      Navigator.pushNamed(
        context,
        '/table-order',
        arguments: TableOrderArgs(
          tableId: order.tableId,
          tableName: order.reference,
        ),
      );
    } else if (type == 'group') {
      Navigator.pushNamed(
        context,
        '/group-order',
        arguments: GroupOrderArgs(
          groupName: order.reference,
          peopleCount: order.guests,
          contactName: order.contact ?? '',
          contactPhone: '',
          notes: order.status,
          type: order.channel,
        ),
      );
    } else if (type == 'pickup') {
      Navigator.pushNamed(context, '/pickup-order');
    } else {
      Navigator.pushNamed(
        context,
        '/order-screen',
        arguments: OrderScreenArgs(
          contextLabel: 'Checkout • ${order.type} ${order.reference}',
          channel: _channelFromString(order.channel),
        ),
      );
    }
  }

  OrderChannel _channelFromString(String raw) {
    switch (raw.toLowerCase()) {
      case 'table':
        return OrderChannel.table;
      case 'group':
        return OrderChannel.group;
      case 'pickup':
        return OrderChannel.pickup;
      case 'quick_billing':
      case 'quick billing':
        return OrderChannel.quickBilling;
      case 'delivery':
        return OrderChannel.delivery;
      case 'online':
        return OrderChannel.online;
      default:
        return OrderChannel.quickBilling;
    }
  }

  void _showCreateOrderSheet() {
    final parentContext = context;
    final options = [
      _OrderCreationOption(
        title: 'Table Order',
        description: 'Assign guests to an available table.',
        icon: Icons.table_bar,
        route: '/tables',
        arguments: TablesScreenArgs(
          allowManageTables: widget.allowTableManagement,
          dashboardRoute: widget.dashboardRoute,
        ),
      ),
      _OrderCreationOption(
        title: 'Group Order',
        description: 'Create or manage a group booking.',
        icon: Icons.groups,
        route: '/groups',
      ),
      _OrderCreationOption(
        title: 'Pickup Order',
        description: 'Handle online or phone pickup.',
        icon: Icons.delivery_dining,
        route: '/pickup-order',
      ),
      _OrderCreationOption(
        title: 'Quick Billing',
        description: 'Counter order or walk-in billing.',
        icon: Icons.flash_on,
        route: '/quick-billing',
      ),
    ];

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(height: 16),
            Text(
              'Start a new order',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ...options.map(
              (option) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: Colors.grey.shade200,
                  child: Icon(option.icon, color: Colors.grey.shade800),
                ),
                title: Text(option.title),
                subtitle: Text(option.description),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(sheetContext);
                  Navigator.pushNamed(
                    parentContext,
                    option.route,
                    arguments: option.arguments,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final ActiveOrderEntity order;
  final VoidCallback onTap;

  const _OrderCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = (order.tableName ?? '').isNotEmpty
        ? order.tableName!
        : '${order.type} • ${order.reference}';
    final startedAt = _formatOrderTimestamp(order.startedAt);
    final subtitleParts = <String>[
      'Items: ${order.itemsCount}',
      if (startedAt.isNotEmpty) 'Started $startedAt',
    ];
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          subtitleParts.join(' • '),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatCurrency(order.amount),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    avatar: const Icon(Icons.label, size: 18),
                    label: Text(order.type),
                  ),
                  Chip(
                    avatar: const Icon(Icons.timelapse, size: 18),
                    label: Text(order.status),
                  ),

                  // if (order.guests > 0)
                  //   Chip(
                  //     avatar: const Icon(Icons.group, size: 18),
                  //     label: Text('Guests: ${order.guests}'),
                  //   ),
                ],
              ),
              if (order.contact != null)
                Text(order.contact!, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrdersSummary extends StatelessWidget {
  final int activeCount;
  final int pendingBilling;
  final double totalValue;

  const _OrdersSummary({
    required this.activeCount,
    required this.pendingBilling,
    required this.totalValue,
  });

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: _SummaryColumn(
                title: 'Active',
                value: '$activeCount',
                subtitle: 'Orders in progress',
                color: Colors.blue,
              ),
            ),
            Expanded(
              child: _SummaryColumn(
                title: 'Order Value',
                value: _formatCurrency(totalValue),
                subtitle: 'Potential revenue',
                color: Colors.orange,
              ),
            ),
            Expanded(
              child: _SummaryColumn(
                title: 'Pending',
                value: '$pendingBilling',
                subtitle: 'Awaiting checkout',
                color: Colors.pink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryColumn extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  const _SummaryColumn({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _OrderCreationOption {
  final String title;
  final String description;
  final IconData icon;
  final String route;
  final Object? arguments;

  const _OrderCreationOption({
    required this.title,
    required this.description,
    required this.icon,
    required this.route,
    this.arguments,
  });
}

String _formatCurrency(double value) => '\$${value.toStringAsFixed(2)}';

String _formatOrderTimestamp(String raw) {
  if (raw.isEmpty) return '';
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) return raw;

  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  final local = parsed.toLocal();
  final month = months[local.month - 1];
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  final period = local.hour >= 12 ? 'PM' : 'AM';
  final datePart =
      '${month} ${local.day}${local.year != DateTime.now().year ? ', ${local.year}' : ''}';

  return '$datePart • $hour:$minute $period';
}
