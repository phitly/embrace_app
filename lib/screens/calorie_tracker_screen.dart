import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/services.dart';
import '../models/models.dart';

class CalorieTrackerScreen extends StatefulWidget {
  const CalorieTrackerScreen({super.key});

  @override
  State<CalorieTrackerScreen> createState() => _CalorieTrackerScreenState();
}

class _CalorieTrackerScreenState extends State<CalorieTrackerScreen> {
  List<CalorieEntry> _entries = [];
  int _totalCalories = 0;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final dbHelper = Provider.of<DatabaseHelper>(context, listen: false);
    final entries = await dbHelper.getTodayCalorieEntries();
    final total = await dbHelper.getTodayTotalCalories();
    setState(() {
      _entries = entries;
      _totalCalories = total;
    });
  }

  void _showAddFoodDialog() {
    final foodNameController = TextEditingController();
    final caloriesController = TextEditingController();
    final quantityController = TextEditingController();
    final unitController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Food Entry'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: foodNameController,
                decoration: const InputDecoration(
                  labelText: 'Food Name',
                  hintText: 'e.g., Apple, Chicken Breast, Rice',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: caloriesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Calories',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantity (optional)',
                  hintText: 'e.g., 100, 1.5',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: unitController,
                decoration: const InputDecoration(
                  labelText: 'Unit (optional)',
                  hintText: 'e.g., g, cups, pieces',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _addFood(
              foodNameController.text,
              caloriesController.text,
              quantityController.text,
              unitController.text,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _addFood(
    String foodName,
    String calories,
    String quantity,
    String unit,
  ) async {
    if (foodName.isEmpty || calories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in food name and calories'),
        ),
      );
      return;
    }

    final entry = CalorieEntry(
      foodName: foodName,
      calories: int.tryParse(calories) ?? 0,
      date: DateTime.now(),
      quantity: quantity.isNotEmpty ? double.tryParse(quantity) : null,
      unit: unit.isNotEmpty ? unit : null,
    );

    final dbHelper = Provider.of<DatabaseHelper>(context, listen: false);
    await dbHelper.insertCalorieEntry(entry);
    
    Navigator.pop(context);
    _loadEntries();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Food entry added successfully!'),
      ),
    );
  }

  Future<void> _deleteFood(CalorieEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Food Entry'),
        content: Text('Are you sure you want to delete "${entry.foodName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final dbHelper = Provider.of<DatabaseHelper>(context, listen: false);
      await dbHelper.deleteCalorieEntry(entry.id!);
      _loadEntries();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Food entry deleted successfully'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calorie Tracker'),
      ),
      body: Column(
        children: [
          // Daily total card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        color: Colors.orange,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Today\'s Total',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '$_totalCalories cal',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Entries list
          Expanded(
            child: _entries.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.restaurant,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No food logged today',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap + to add your first meal',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _entries.length,
                    itemBuilder: (context, index) {
                      final entry = _entries[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.restaurant),
                          title: Text(entry.foodName),
                          subtitle: entry.quantity != null && entry.unit != null
                              ? Text('${entry.quantity} ${entry.unit}')
                              : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${entry.calories} cal',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'delete') {
                                    _deleteFood(entry);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Delete'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddFoodDialog(),
        heroTag: "calorie_fab",
        child: const Icon(Icons.add),
      ),
    );
  }
}