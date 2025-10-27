import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../services/services.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  Map<String, int> _weeklyWorkouts = {};
  Map<String, int> _weeklyCalories = {};

  @override
  void initState() {
    super.initState();
    _loadProgressData();
  }

  Future<void> _loadProgressData() async {
    final dbHelper = Provider.of<DatabaseHelper>(context, listen: false);
    final workouts = await dbHelper.getWeeklyWorkoutCounts();
    final calories = await dbHelper.getWeeklyCalorieCounts();
    
    setState(() {
      _weeklyWorkouts = workouts;
      _weeklyCalories = calories;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Workout Progress',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: 200,
                  child: _weeklyWorkouts.isEmpty
                      ? const Center(
                          child: Text('No workout data available'),
                        )
                      : BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: _weeklyWorkouts.values.isNotEmpty
                                ? _weeklyWorkouts.values.reduce((a, b) => a > b ? a : b).toDouble() + 1
                                : 5,
                            barTouchData: BarTouchData(enabled: false),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (double value, TitleMeta meta) {
                                    final keys = _weeklyWorkouts.keys.toList();
                                    if (value.toInt() < keys.length) {
                                      return Text(keys[value.toInt()]);
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                              leftTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            barGroups: _weeklyWorkouts.entries.map((entry) {
                              final index = _weeklyWorkouts.keys.toList().indexOf(entry.key);
                              return BarChartGroupData(
                                x: index,
                                barRods: [
                                  BarChartRodData(
                                    toY: entry.value.toDouble(),
                                    color: Colors.blue,
                                    width: 16,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              'Weekly Calorie Intake',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: 200,
                  child: _weeklyCalories.isEmpty
                      ? const Center(
                          child: Text('No calorie data available'),
                        )
                      : LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: false),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (double value, TitleMeta meta) {
                                    final keys = _weeklyCalories.keys.toList();
                                    if (value.toInt() < keys.length) {
                                      return Text(keys[value.toInt()]);
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                              leftTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: _weeklyCalories.entries.map((entry) {
                                  final index = _weeklyCalories.keys.toList().indexOf(entry.key);
                                  return FlSpot(index.toDouble(), entry.value.toDouble());
                                }).toList(),
                                isCurved: true,
                                color: Colors.orange,
                                barWidth: 3,
                                dotData: const FlDotData(show: true),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: Colors.orange.withOpacity(0.1),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Summary cards
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.fitness_center,
                            size: 32,
                            color: Colors.blue,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_weeklyWorkouts.values.fold<int>(0, (sum, count) => sum + count)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text('This Week'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.local_fire_department,
                            size: 32,
                            color: Colors.orange,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_weeklyCalories.values.fold<int>(0, (sum, count) => sum + count)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text('Total Calories'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}