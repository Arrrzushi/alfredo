import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/neomorphic_container.dart';
import '../models/pantry_item.dart';
import '../models/shopping_item.dart';

class SmartPantryScreen extends StatefulWidget {
  const SmartPantryScreen({super.key});

  @override
  State<SmartPantryScreen> createState() => _SmartPantryScreenState();
}

class _SmartPantryScreenState extends State<SmartPantryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<PantryItem> _pantryItems = [
    PantryItem(
      id: '1',
      name: 'Spinach',
      quantity: 200,
      unit: 'g',
      category: 'Vegetables',
      expiryDate: DateTime.now().add(const Duration(days: 3)),
    ),
    PantryItem(
      id: '2',
      name: 'Paneer',
      quantity: 250,
      unit: 'g',
      category: 'Dairy',
      expiryDate: DateTime.now().add(const Duration(days: 5)),
    ),
    PantryItem(
      id: '3',
      name: 'Banana',
      quantity: 4,
      unit: 'pieces',
      category: 'Fruits',
      expiryDate: DateTime.now().add(const Duration(days: 2)),
    ),
    PantryItem(
      id: '4',
      name: 'Oats',
      quantity: 500,
      unit: 'g',
      category: 'Grains',
    ),
    PantryItem(
      id: '5',
      name: 'Milk',
      quantity: 1,
      unit: 'L',
      category: 'Dairy',
      expiryDate: DateTime.now().add(const Duration(days: 4)),
    ),
    PantryItem(
      id: '6',
      name: 'Tomatoes',
      quantity: 500,
      unit: 'g',
      category: 'Vegetables',
      expiryDate: DateTime.now().add(const Duration(days: 5)),
    ),
    PantryItem(
      id: '7',
      name: 'Onions',
      quantity: 1,
      unit: 'kg',
      category: 'Vegetables',
      expiryDate: DateTime.now().add(const Duration(days: 7)),
    ),
    PantryItem(
      id: '8',
      name: 'Eggs',
      quantity: 12,
      unit: 'pieces',
      category: 'Dairy',
      expiryDate: DateTime.now().add(const Duration(days: 6)),
    ),
    PantryItem(
      id: '9',
      name: 'Rice',
      quantity: 2,
      unit: 'kg',
      category: 'Grains',
    ),
    PantryItem(
      id: '10',
      name: 'Chicken Breast',
      quantity: 500,
      unit: 'g',
      category: 'Meat',
      expiryDate: DateTime.now().add(const Duration(days: 1)),
    ),
  ];

  final List<ShoppingItem> _shoppingItems = [
    ShoppingItem(
      id: '1',
      name: 'Tomatoes',
      quantity: 500,
      unit: 'g',
      category: 'Vegetables',
    ),
    ShoppingItem(
      id: '2',
      name: 'Onions',
      quantity: 1,
      unit: 'kg',
      category: 'Vegetables',
    ),
    ShoppingItem(
      id: '3',
      name: 'Bread',
      quantity: 1,
      unit: 'loaf',
      category: 'Bakery',
      isCompleted: true,
    ),
    ShoppingItem(
      id: '4',
      name: 'Eggs',
      quantity: 12,
      unit: 'pieces',
      category: 'Dairy',
    ),
    ShoppingItem(
      id: '5',
      name: 'Yogurt',
      quantity: 500,
      unit: 'g',
      category: 'Dairy',
    ),
    ShoppingItem(
      id: '6',
      name: 'Carrots',
      quantity: 500,
      unit: 'g',
      category: 'Vegetables',
    ),
    ShoppingItem(
      id: '7',
      name: 'Olive Oil',
      quantity: 1,
      unit: 'bottle',
      category: 'Condiments',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<PantryItem> get _lowStockItems => _pantryItems.where((item) {
        if (item.expiryDate == null) return false;
        final daysUntilExpiry = item.expiryDate!.difference(DateTime.now()).inDays;
        return daysUntilExpiry <= 2;
      }).toList();

  List<PantryItem> get _expiringSoonItems => _pantryItems.where((item) {
        if (item.expiryDate == null) return false;
        final daysUntilExpiry = item.expiryDate!.difference(DateTime.now()).inDays;
        return daysUntilExpiry <= 3 && daysUntilExpiry >= 0;
      }).toList();

  Map<String, int> get _categoryCount {
    final Map<String, int> counts = {};
    for (var item in _pantryItems) {
      if (item.category != null) {
        counts[item.category!] = (counts[item.category!] ?? 0) + 1;
      }
    }
    return counts;
  }

  double get _averageExpiryDays {
    final itemsWithExpiry = _pantryItems.where((item) => item.expiryDate != null).toList();
    if (itemsWithExpiry.isEmpty) return 0;
    final totalDays = itemsWithExpiry.fold(0.0, (sum, item) {
      final days = item.expiryDate!.difference(DateTime.now()).inDays;
      return sum + (days > 0 ? days : 0);
    });
    return totalDays / itemsWithExpiry.length;
  }

  double get _estimatedPantryValue => _pantryItems.length * 2.5;
  double get _estimatedShoppingCost => _shoppingItems.where((item) => !item.isCompleted).length * 3.0;

  void _updateItemQuantity(int index, double newQuantity) {
    setState(() {
      if (newQuantity <= 0) {
        _pantryItems.removeAt(index);
      } else {
        final item = _pantryItems[index];
        _pantryItems[index] = PantryItem(
          id: item.id,
          name: item.name,
          quantity: newQuantity,
          unit: item.unit,
          expiryDate: item.expiryDate,
          category: item.category,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Pantry'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryOrange,
          unselectedLabelColor: AppTheme.gray600,
          indicatorColor: AppTheme.primaryOrange,
          tabs: const [
            Tab(text: 'Pantry'),
            Tab(text: 'Shopping'),
            Tab(text: 'Low Stock'),
            Tab(text: 'Analytics'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPantryTab(),
          _buildShoppingTab(),
          _buildLowStockTab(),
          _buildAnalyticsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Add new item
        },
        backgroundColor: AppTheme.primaryOrange,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Item'),
      ),
    );
  }

  Widget _buildPantryTab() {
    return SafeArea(
      child: Column(
        children: [
          // Quick Stats Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryOrange.withValues(alpha: 0.05),
              border: Border(
                bottom: BorderSide(color: AppTheme.gray200, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickStat('${_pantryItems.length}', 'Items', Icons.inventory_2_rounded),
                Container(width: 1, height: 30, color: AppTheme.gray300),
                _buildQuickStat('${_expiringSoonItems.length}', 'Expiring', Icons.schedule_rounded),
                Container(width: 1, height: 30, color: AppTheme.gray300),
                _buildQuickStat('₹${(_estimatedPantryValue * 83).toStringAsFixed(0)}', 'Value', Icons.currency_rupee_rounded),
              ],
            ),
          ),

          // Pantry Items List
          Expanded(
            child: _pantryItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.kitchen_outlined,
                          size: 64,
                          color: AppTheme.gray400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Your pantry is empty',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppTheme.gray600,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap + to add items',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.gray500,
                              ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _pantryItems.length,
                    itemBuilder: (context, index) {
                      final item = _pantryItems[index];
                      return _buildModernPantryItem(item, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernPantryItem(PantryItem item, int index) {
    final daysUntilExpiry = item.expiryDate?.difference(DateTime.now()).inDays;
    final isExpiringSoon = daysUntilExpiry != null && daysUntilExpiry <= 3;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showItemDetails(item, index),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Category Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(item.category).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getCategoryIcon(item.category),
                    color: _getCategoryColor(item.category),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),

                // Item Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              item.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          if (isExpiringSoon) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$daysUntilExpiry d',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 10,
                                    ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Text(
                            '${item.quantity} ${item.unit}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.gray700,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          if (item.category?.isNotEmpty ?? false)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.gray100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                item.category!,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.gray600,
                                      fontSize: 11,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Quantity Controls
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.gray50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_rounded, size: 18),
                        color: AppTheme.primaryOrange,
                        padding: const EdgeInsets.all(6),
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        onPressed: () {
                          if (item.quantity > 0.5) {
                            _updateItemQuantity(index, item.quantity - 0.5);
                          }
                        },
                      ),
                      Container(
                        constraints: const BoxConstraints(minWidth: 40, maxWidth: 60),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        child: Text(
                          item.quantity.toStringAsFixed(item.quantity % 1 == 0 ? 0 : 1),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.gray900,
                              ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_rounded, size: 18),
                        color: AppTheme.primaryOrange,
                        padding: const EdgeInsets.all(6),
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        onPressed: () {
                          _updateItemQuantity(index, item.quantity + 0.5);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showItemDetails(PantryItem item, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.gray400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: _getCategoryColor(item.category).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            _getCategoryIcon(item.category),
                            color: _getCategoryColor(item.category),
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                              if (item.category != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  item.category!,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppTheme.gray600,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildDetailRow('Quantity', '${item.quantity} ${item.unit}'),
                    if (item.expiryDate != null) ...[
                      const SizedBox(height: 16),
                      _buildDetailRow(
                        'Expiry Date',
                        '${item.expiryDate!.day}/${item.expiryDate!.month}/${item.expiryDate!.year}',
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow(
                        'Days Left',
                        '${item.expiryDate!.difference(DateTime.now()).inDays} days',
                      ),
                    ],
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _showEditDialog(item, index);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryOrange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Edit Quantity'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.gray600,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  void _showEditDialog(PantryItem item, int index) {
    final quantityController = TextEditingController(text: item.quantity.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit ${item.name}'),
        content: TextField(
          controller: quantityController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Quantity',
            suffixText: item.unit,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.primaryOrange, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              quantityController.dispose();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newQuantity = double.tryParse(quantityController.text);
              if (newQuantity != null && newQuantity > 0) {
                _updateItemQuantity(index, newQuantity);
                quantityController.dispose();
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid quantity'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryOrange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryOrange, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.gray900,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.gray600,
                fontSize: 11,
              ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String? category) {
    switch (category) {
      case 'Vegetables':
        return Colors.green;
      case 'Fruits':
        return Colors.red;
      case 'Dairy':
        return Colors.blue;
      case 'Meat':
        return Colors.brown;
      case 'Grains':
        return Colors.amber;
      default:
        return AppTheme.primaryOrange;
    }
  }

  IconData _getCategoryIcon(String? category) {
    switch (category) {
      case 'Vegetables':
        return Icons.eco_rounded;
      case 'Fruits':
        return Icons.apple_rounded;
      case 'Dairy':
        return Icons.local_drink_rounded;
      case 'Meat':
        return Icons.set_meal_rounded;
      case 'Grains':
        return Icons.breakfast_dining_rounded;
      default:
        return Icons.kitchen_rounded;
    }
  }

  Widget _buildShoppingTab() {
    final pendingItems = _shoppingItems.where((item) => !item.isCompleted).toList();
    final completedItems = _shoppingItems.where((item) => item.isCompleted).toList();

    return SafeArea(
      child: Column(
        children: [
          // Shopping Stats
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryOrange.withValues(alpha: 0.05),
              border: Border(
                bottom: BorderSide(color: AppTheme.gray200, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickStat('${pendingItems.length}', 'Pending', Icons.pending_rounded),
                Container(width: 1, height: 30, color: AppTheme.gray300),
                _buildQuickStat('${completedItems.length}', 'Done', Icons.check_circle_rounded),
                Container(width: 1, height: 30, color: AppTheme.gray300),
                _buildQuickStat('₹${(_estimatedShoppingCost * 83).toStringAsFixed(0)}', 'Est. Cost', Icons.currency_rupee_rounded),
              ],
            ),
          ),

          // Shopping List
          Expanded(
            child: _shoppingItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined, size: 64, color: AppTheme.gray400),
                        const SizedBox(height: 16),
                        Text(
                          'No items in shopping list',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppTheme.gray600,
                              ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _shoppingItems.length,
                    itemBuilder: (context, index) {
                      final item = _shoppingItems[index];
                      return _buildShoppingItem(item, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildShoppingItem(ShoppingItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            setState(() {
              _shoppingItems[index] = ShoppingItem(
                id: item.id,
                name: item.name,
                quantity: item.quantity,
                unit: item.unit,
                category: item.category,
                isCompleted: !item.isCompleted,
              );
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Checkbox(
                  value: item.isCompleted,
                  onChanged: (value) {
                    setState(() {
                      _shoppingItems[index] = ShoppingItem(
                        id: item.id,
                        name: item.name,
                        quantity: item.quantity,
                        unit: item.unit,
                        category: item.category,
                        isCompleted: value ?? false,
                      );
                    });
                  },
                  activeColor: AppTheme.primaryOrange,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              decoration: item.isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              color: item.isCompleted ? AppTheme.gray500 : AppTheme.gray900,
                            ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        children: [
                          Text(
                            '${item.quantity} ${item.unit}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.gray600,
                                ),
                          ),
                          if (item.category != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.gray100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item.category!,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.gray600,
                                      fontSize: 10,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLowStockTab() {
    return SafeArea(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.05),
              border: Border(
                bottom: BorderSide(color: AppTheme.gray200, width: 1),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_rounded, color: Colors.orange, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Low Stock Alert',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        '${_lowStockItems.length} items need attention',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.gray600,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _lowStockItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline_rounded, size: 64, color: Colors.green),
                        const SizedBox(height: 16),
                        Text(
                          'All items are well stocked!',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppTheme.gray600,
                              ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _lowStockItems.length,
                    itemBuilder: (context, index) {
                      final item = _lowStockItems[index];
                      final originalIndex = _pantryItems.indexWhere((i) => i.id == item.id);
                      return _buildModernPantryItem(item, originalIndex);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pantry Analytics',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            NeomorphicContainer(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overview',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildMetricRow('Total Items', '${_pantryItems.length}', Icons.inventory_2_rounded),
                  const SizedBox(height: 12),
                  _buildMetricRow('Categories', '${_categoryCount.length}', Icons.category_rounded),
                  const SizedBox(height: 12),
                  _buildMetricRow('Expiring Soon', '${_expiringSoonItems.length}', Icons.schedule_rounded),
                  const SizedBox(height: 12),
                  _buildMetricRow('Avg. Days Left', '${_averageExpiryDays.toStringAsFixed(1)} days', Icons.calendar_today_rounded),
                  const SizedBox(height: 12),
                  _buildMetricRow('Est. Value', '₹${(_estimatedPantryValue * 83).toStringAsFixed(0)}', Icons.currency_rupee_rounded),
                ],
              ),
            ),
            const SizedBox(height: 20),
            NeomorphicContainer(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'By Category',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ..._categoryCount.entries.map((entry) {
                    final percentage = (entry.value / _pantryItems.length * 100);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getCategoryIcon(entry.key),
                                      size: 16,
                                      color: _getCategoryColor(entry.key),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        entry.key,
                                        style: Theme.of(context).textTheme.bodyMedium,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${entry.value} (${percentage.toStringAsFixed(0)}%)',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.gray600,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: percentage / 100,
                              backgroundColor: AppTheme.gray200,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getCategoryColor(entry.key),
                              ),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryOrange),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
