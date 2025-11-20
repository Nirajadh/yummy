import 'package:flutter/material.dart';

class TableInfo {
  final String name;
  final int capacity;
  final String status;
  final String notes;
  final List<String> activeItems;
  final List<String> pastOrders;
  final String? reservationName;

  const TableInfo({
    required this.name,
    required this.capacity,
    required this.status,
    this.notes = '',
    this.activeItems = const [],
    this.pastOrders = const [],
    this.reservationName,
  });
}

class GroupInfo {
  final String name;
  final int peopleCount;
  final String contactName;
  final String contactPhone;
  final String type;
  final String notes;
  final bool isActive;

  const GroupInfo({
    required this.name,
    required this.peopleCount,
    required this.contactName,
    required this.contactPhone,
    required this.type,
    this.notes = '',
    this.isActive = true,
  });
}

class MenuItemModel {
  final String name;
  final String category;
  final double price;
  final String description;

  const MenuItemModel({
    required this.name,
    required this.category,
    required this.price,
    this.description = '',
  });
}

class OrderHistoryEntry {
  final String id;
  final String type;
  final double amount;
  final String status;
  final String timestamp;

  const OrderHistoryEntry({
    required this.id,
    required this.type,
    required this.amount,
    required this.status,
    required this.timestamp,
  });
}

class KotTicket {
  final String id;
  final String type;
  final String reference;
  final List<String> items;
  final String time;
  final String status;

  const KotTicket({
    required this.id,
    required this.type,
    required this.reference,
    required this.items,
    required this.time,
    this.status = 'Pending',
  });
}

class DashboardMetric {
  final String title;
  final String value;
  final double trend;
  final IconData icon;
  final Color color;

  const DashboardMetric({
    required this.title,
    required this.value,
    required this.trend,
    required this.icon,
    required this.color,
  });
}

class ActiveOrder {
  final String id;
  final String type;
  final String reference;
  final double amount;
  final int itemsCount;
  final int guests;
  final String startedAt;
  final String status;
  final String channel;
  final String? contact;

  const ActiveOrder({
    required this.id,
    required this.type,
    required this.reference,
    required this.amount,
    required this.itemsCount,
    required this.guests,
    required this.startedAt,
    required this.status,
    required this.channel,
    this.contact,
  });
}

class ExpenseEntry {
  final String category;
  final String vendor;
  final double amount;
  final String date;
  final String paymentMode;
  final String notes;

  const ExpenseEntry({
    required this.category,
    required this.vendor,
    required this.amount,
    required this.date,
    required this.paymentMode,
    required this.notes,
  });
}

class StaffMember {
  final String name;
  final String role;
  final double salary;
  final String phone;
  final String email;
  final String joinedDate;
  final String status;
  final String shift;
  final String? notes;

  const StaffMember({
    required this.name,
    required this.role,
    required this.salary,
    required this.phone,
    required this.email,
    required this.joinedDate,
    required this.status,
    required this.shift,
    this.notes,
  });
}

class StaffRecord {
  final String staffName;
  final String type;
  final double amount;
  final String date;
  final String note;

  const StaffRecord({
    required this.staffName,
    required this.type,
    required this.amount,
    required this.date,
    required this.note,
  });
}

class PurchaseEntry {
  final String vendor;
  final String category;
  final double amount;
  final String date;
  final String reference;

  const PurchaseEntry({
    required this.vendor,
    required this.category,
    required this.amount,
    required this.date,
    required this.reference,
  });
}

class IncomeEntry {
  final String source;
  final double amount;
  final String date;
  final String type;
  final String note;

  const IncomeEntry({
    required this.source,
    required this.amount,
    required this.date,
    required this.type,
    required this.note,
  });
}

const statusColors = <String, Color>{
  'FREE': Colors.green,
  'OCCUPIED': Colors.red,
  'BILL PRINTED': Colors.orange,
  'RESERVED': Colors.blue,
};

const dashboardMetrics = <DashboardMetric>[
  DashboardMetric(
    title: 'Analytics',
    value: '85% Efficiency',
    trend: 4.2,
    icon: Icons.insights,
    color: Colors.indigo,
  ),
  DashboardMetric(
    title: 'Sales',
    value: '\$48.6K',
    trend: 6.1,
    icon: Icons.point_of_sale,
    color: Colors.deepOrange,
  ),
  DashboardMetric(
    title: 'History',
    value: '248 Orders',
    trend: 2.4,
    icon: Icons.history,
    color: Colors.blueGrey,
  ),
  DashboardMetric(
    title: 'Purchase',
    value: '\$12.4K',
    trend: -1.3,
    icon: Icons.shopping_cart,
    color: Colors.teal,
  ),
  DashboardMetric(
    title: 'Income',
    value: '\$32.1K',
    trend: 3.7,
    icon: Icons.account_balance_wallet,
    color: Colors.green,
  ),
  DashboardMetric(
    title: 'Expenses',
    value: '\$8.2K',
    trend: 1.1,
    icon: Icons.request_page,
    color: Colors.redAccent,
  ),
];

const dummyActiveOrders = <ActiveOrder>[
  ActiveOrder(
    id: 'ORD-145',
    type: 'Table',
    reference: 'T2',
    amount: 126.40,
    itemsCount: 5,
    guests: 2,
    startedAt: '18:32',
    status: 'Preparing',
    channel: 'Dine-In',
    contact: 'Handled by Sima',
  ),
  ActiveOrder(
    id: 'ORD-152',
    type: 'Pickup',
    reference: 'PK-5123',
    amount: 42.50,
    itemsCount: 3,
    guests: 0,
    startedAt: '18:40',
    status: 'Ready',
    channel: 'Pickup',
    contact: 'Ashwin • +1 555-1010',
  ),
  ActiveOrder(
    id: 'ORD-149',
    type: 'Group',
    reference: 'Corporate Suite',
    amount: 512.20,
    itemsCount: 18,
    guests: 10,
    startedAt: '17:58',
    status: 'Serving',
    channel: 'Banquet',
    contact: 'Salma (Host)',
  ),
  ActiveOrder(
    id: 'ORD-155',
    type: 'Quick Billing',
    reference: 'POS-09',
    amount: 28.30,
    itemsCount: 2,
    guests: 1,
    startedAt: '18:55',
    status: 'Payment Pending',
    channel: 'Counter',
    contact: 'Walk-in',
  ),
];

const dummyExpenses = <ExpenseEntry>[
  ExpenseEntry(
    category: 'Supplies',
    vendor: 'Fresh Farms Co.',
    amount: 420.50,
    date: 'Apr 10, 2024',
    paymentMode: 'Bank Transfer',
    notes: 'Weekly vegetables and dairy',
  ),
  ExpenseEntry(
    category: 'Utilities',
    vendor: 'City Power & Gas',
    amount: 310.00,
    date: 'Apr 09, 2024',
    paymentMode: 'Auto Debit',
    notes: 'Electricity and gas invoices',
  ),
  ExpenseEntry(
    category: 'Staffing',
    vendor: 'Weekend Overtime',
    amount: 680.00,
    date: 'Apr 08, 2024',
    paymentMode: 'Cash',
    notes: 'Additional shift payouts',
  ),
  ExpenseEntry(
    category: 'Maintenance',
    vendor: 'EquipCare Services',
    amount: 240.75,
    date: 'Apr 06, 2024',
    paymentMode: 'Credit Card',
    notes: 'Kitchen equipment tune-up',
  ),
  ExpenseEntry(
    category: 'Marketing',
    vendor: 'Social Spark Ads',
    amount: 180.00,
    date: 'Apr 05, 2024',
    paymentMode: 'UPI',
    notes: 'Weekend promotions',
  ),
];

const dummyStaffMembers = <StaffMember>[
  StaffMember(
    name: 'Ava Martin',
    role: 'Manager',
    salary: 3200,
    phone: '+1 555-1111',
    email: 'ava@myrestro.com',
    joinedDate: 'Jan 2022',
    status: 'Active',
    shift: 'Morning',
    notes: 'Handles vendor coordination',
  ),
  StaffMember(
    name: 'Ravi Patel',
    role: 'Server',
    salary: 1800,
    phone: '+1 555-2222',
    email: 'ravi@myrestro.com',
    joinedDate: 'Aug 2023',
    status: 'Active',
    shift: 'Evening',
    notes: 'Strong upselling skills',
  ),
  StaffMember(
    name: 'Lina Chen',
    role: 'Chef',
    salary: 2600,
    phone: '+1 555-3333',
    email: 'lina@myrestro.com',
    joinedDate: 'Mar 2021',
    status: 'On Leave',
    shift: 'Morning',
    notes: 'Specializes in desserts',
  ),
  StaffMember(
    name: 'Samir Khan',
    role: 'Cashier',
    salary: 1900,
    phone: '+1 555-4444',
    email: 'samir@myrestro.com',
    joinedDate: 'Oct 2022',
    status: 'Active',
    shift: 'Split',
  ),
];

const dummyStaffRecords = <StaffRecord>[
  StaffRecord(
    staffName: 'Ava Martin',
    type: 'Salary Paid',
    amount: 3200,
    date: 'Apr 25, 2024',
    note: 'April payout processed',
  ),
  StaffRecord(
    staffName: 'Ravi Patel',
    type: 'Salary Paid',
    amount: 1800,
    date: 'Apr 25, 2024',
    note: 'April payout with tips adjustment',
  ),
  StaffRecord(
    staffName: 'Lina Chen',
    type: 'Allowance',
    amount: 150,
    date: 'Mar 30, 2024',
    note: 'Festival bonus',
  ),
  StaffRecord(
    staffName: 'Samir Khan',
    type: 'Advance',
    amount: 300,
    date: 'Apr 05, 2024',
    note: 'Approved by manager',
  ),
];

const dummyPurchases = <PurchaseEntry>[
  PurchaseEntry(
    vendor: 'Fresh Farms Co.',
    category: 'Produce',
    amount: 450.75,
    date: 'Apr 12, 2024',
    reference: 'INV-2201',
  ),
  PurchaseEntry(
    vendor: 'City Power & Gas',
    category: 'Utilities',
    amount: 310.00,
    date: 'Apr 09, 2024',
    reference: 'INV-2200',
  ),
  PurchaseEntry(
    vendor: 'EquipCare Services',
    category: 'Maintenance',
    amount: 240.75,
    date: 'Apr 06, 2024',
    reference: 'INV-2195',
  ),
  PurchaseEntry(
    vendor: 'Social Spark Ads',
    category: 'Marketing',
    amount: 180.00,
    date: 'Apr 05, 2024',
    reference: 'INV-2192',
  ),
];

const dummyIncome = <IncomeEntry>[
  IncomeEntry(
    source: 'Online Orders',
    amount: 12450.00,
    date: 'Apr 15, 2024',
    type: 'Sales',
    note: 'Platform payout',
  ),
  IncomeEntry(
    source: 'Dine-In',
    amount: 18420.50,
    date: 'Apr 15, 2024',
    type: 'Sales',
    note: 'Card + cash receipts',
  ),
  IncomeEntry(
    source: 'Catering',
    amount: 5200.00,
    date: 'Apr 14, 2024',
    type: 'Corporate',
    note: 'Invoice cleared',
  ),
  IncomeEntry(
    source: 'Tips',
    amount: 890.00,
    date: 'Apr 14, 2024',
    type: 'Staff',
    note: 'Tipped out to staff pool',
  ),
];

const dummyTables = <TableInfo>[
  TableInfo(
    name: 'T1',
    capacity: 4,
    status: 'FREE',
    notes: 'Window corner',
    pastOrders: ['ORD-090 • \$75.40', 'ORD-082 • \$64.20'],
  ),
  TableInfo(
    name: 'T2',
    capacity: 2,
    status: 'OCCUPIED',
    notes: 'VIP guest',
    activeItems: ['Margherita Pizza x1', 'Lemonade x2', 'Cheesecake x1'],
    pastOrders: ['ORD-105 • \$120.00'],
  ),
  TableInfo(
    name: 'T3',
    capacity: 6,
    status: 'RESERVED',
    reservationName: 'Patel Family',
    notes: 'Arriving at 8 PM',
    pastOrders: ['ORD-077 • \$240.30'],
  ),
  TableInfo(
    name: 'T4',
    capacity: 4,
    status: 'BILL PRINTED',
    activeItems: ['Veggie Burger x2', 'Iced Tea x2'],
    pastOrders: ['ORD-111 • \$86.00'],
  ),
  TableInfo(
    name: 'T5',
    capacity: 8,
    status: 'OCCUPIED',
    activeItems: ['Tandoori Platter x1', 'Mango Lassi x4', 'Brownie Sundae x2'],
    pastOrders: ['ORD-130 • \$310.75', 'ORD-125 • \$280.40'],
  ),
  TableInfo(
    name: 'T6',
    capacity: 2,
    status: 'FREE',
    notes: 'Near entrance',
  ),
  TableInfo(
    name: 'T7',
    capacity: 4,
    status: 'RESERVED',
    reservationName: 'Corporate booking',
    pastOrders: ['ORD-060 • \$150.90'],
  ),
  TableInfo(
    name: 'T8',
    capacity: 6,
    status: 'FREE',
    pastOrders: ['ORD-070 • \$180.10'],
  ),
  TableInfo(
    name: 'T9',
    capacity: 4,
    status: 'OCCUPIED',
    activeItems: ['Paneer Tikka x1', 'Mojito x3', 'Gulab Jamun x2'],
    pastOrders: ['ORD-140 • \$210.10'],
  ),
  TableInfo(
    name: 'T10',
    capacity: 10,
    status: 'FREE',
    notes: 'Party table',
  ),
];

const dummyGroups = <GroupInfo>[
  GroupInfo(
    name: 'IT Friends',
    peopleCount: 8,
    contactName: 'Nora',
    contactPhone: '555-0101',
    type: 'Friends',
    notes: 'Prefers window seats',
  ),
  GroupInfo(
    name: 'Office Team',
    peopleCount: 12,
    contactName: 'Manu',
    contactPhone: '555-0123',
    type: 'Office',
    notes: 'Corporate account',
  ),
  GroupInfo(
    name: 'Family Dinner',
    peopleCount: 6,
    contactName: 'Priya',
    contactPhone: '555-0156',
    type: 'Family',
  ),
  GroupInfo(
    name: 'Birthday Bash',
    peopleCount: 15,
    contactName: 'Evelyn',
    contactPhone: '555-0198',
    type: 'Birthday',
  ),
  GroupInfo(
    name: 'Start-up Crew',
    peopleCount: 10,
    contactName: 'Leo',
    contactPhone: '555-0112',
    type: 'Friends',
  ),
  GroupInfo(
    name: 'Past Event 1',
    peopleCount: 5,
    contactName: 'Alex',
    contactPhone: '555-0001',
    type: 'Office',
    isActive: false,
  ),
  GroupInfo(
    name: 'Past Event 2',
    peopleCount: 9,
    contactName: 'Sia',
    contactPhone: '555-0002',
    type: 'Family',
    isActive: false,
  ),
];

const menuCategories = <String>[
  'All',
  'Starters',
  'Main Course',
  'Drinks',
  'Desserts',
];

const dummyMenuItems = <MenuItemModel>[
  MenuItemModel(name: 'Garlic Bread', category: 'Starters', price: 4.5),
  MenuItemModel(name: 'Bruschetta', category: 'Starters', price: 5.5),
  MenuItemModel(name: 'Veggie Soup', category: 'Starters', price: 6.0),
  MenuItemModel(name: 'Caesar Salad', category: 'Starters', price: 7.0),
  MenuItemModel(name: 'Paneer Tikka', category: 'Starters', price: 8.5),
  MenuItemModel(name: 'Margherita Pizza', category: 'Main Course', price: 12.0),
  MenuItemModel(name: 'BBQ Chicken Pizza', category: 'Main Course', price: 13.5),
  MenuItemModel(name: 'Veggie Burger', category: 'Main Course', price: 11.0),
  MenuItemModel(name: 'Pasta Alfredo', category: 'Main Course', price: 12.5),
  MenuItemModel(name: 'Grilled Salmon', category: 'Main Course', price: 16.0),
  MenuItemModel(name: 'Steak Frites', category: 'Main Course', price: 18.5),
  MenuItemModel(name: 'Tandoori Platter', category: 'Main Course', price: 17.0),
  MenuItemModel(name: 'Lemonade', category: 'Drinks', price: 3.5),
  MenuItemModel(name: 'Iced Tea', category: 'Drinks', price: 3.0),
  MenuItemModel(name: 'Mojito', category: 'Drinks', price: 4.5),
  MenuItemModel(name: 'Mango Lassi', category: 'Drinks', price: 4.0),
  MenuItemModel(name: 'Chocolate Shake', category: 'Drinks', price: 4.5),
  MenuItemModel(name: 'Cheesecake', category: 'Desserts', price: 6.5),
  MenuItemModel(name: 'Brownie Sundae', category: 'Desserts', price: 6.0),
  MenuItemModel(name: 'Tiramisu', category: 'Desserts', price: 7.5),
  MenuItemModel(name: 'Gulab Jamun', category: 'Desserts', price: 5.0),
  MenuItemModel(name: 'Ice Cream Trio', category: 'Desserts', price: 5.5),
];

const dummyOrderHistory = <OrderHistoryEntry>[
  OrderHistoryEntry(
    id: 'ORD-101',
    type: 'Table',
    amount: 120.50,
    status: 'Paid',
    timestamp: 'Today, 11:20 AM',
  ),
  OrderHistoryEntry(
    id: 'ORD-102',
    type: 'Group',
    amount: 450.00,
    status: 'Unpaid',
    timestamp: 'Today, 11:45 AM',
  ),
  OrderHistoryEntry(
    id: 'ORD-103',
    type: 'Pickup',
    amount: 35.40,
    status: 'Paid',
    timestamp: 'Today, 12:10 PM',
  ),
  OrderHistoryEntry(
    id: 'ORD-104',
    type: 'Quick',
    amount: 18.90,
    status: 'Paid',
    timestamp: 'Yesterday, 9:40 PM',
  ),
  OrderHistoryEntry(
    id: 'ORD-105',
    type: 'Table',
    amount: 210.00,
    status: 'Unpaid',
    timestamp: 'Yesterday, 8:10 PM',
  ),
];

const groupOrderHistory = <String, List<OrderHistoryEntry>>{
  'IT Friends': [
    OrderHistoryEntry(
      id: 'G-201',
      type: 'Group',
      amount: 380.0,
      status: 'Paid',
      timestamp: 'Last week',
    ),
    OrderHistoryEntry(
      id: 'G-225',
      type: 'Group',
      amount: 420.0,
      status: 'Paid',
      timestamp: 'Yesterday',
    ),
  ],
  'Office Team': [
    OrderHistoryEntry(
      id: 'G-330',
      type: 'Group',
      amount: 520.0,
      status: 'Unpaid',
      timestamp: 'Today',
    ),
  ],
};

const dummyKotTickets = <KotTicket>[
  KotTicket(
    id: 'KOT-01',
    type: 'Table',
    reference: 'T2',
    items: ['Margherita Pizza', 'Lemonade x2'],
    time: '11:12 AM',
  ),
  KotTicket(
    id: 'KOT-02',
    type: 'Group',
    reference: 'IT Friends',
    items: ['Tandoori Platter', 'Mango Lassi x4', 'Brownie Sundae x3'],
    time: '11:28 AM',
    status: 'Preparing',
  ),
  KotTicket(
    id: 'KOT-03',
    type: 'Pickup',
    reference: 'Ram',
    items: ['Veggie Burger', 'Iced Tea'],
    time: '11:45 AM',
  ),
];
