import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/services.dart';
import '../models/models.dart';

class RoutinesScreen extends StatefulWidget {
  const RoutinesScreen({super.key});

  @override
  State<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen> {
  List<Routine> _routines = [];
  RoutineLevel? _selectedLevel;

  @override
  void initState() {
    super.initState();
    _loadRoutines();
  }

  Future<void> _loadRoutines() async {
    final dbHelper = Provider.of<DatabaseHelper>(context, listen: false);
    final routines = _selectedLevel != null
        ? await dbHelper.getRoutinesByLevel(_selectedLevel!)
        : await dbHelper.getRoutines();
    setState(() {
      _routines = routines;
    });
  }

  void _filterByLevel(RoutineLevel? level) {
    setState(() {
      _selectedLevel = level;
    });
    _loadRoutines();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Routines'),
        actions: [
          PopupMenuButton<RoutineLevel?>(
            icon: const Icon(Icons.filter_list),
            onSelected: _filterByLevel,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('All Levels'),
              ),
              const PopupMenuItem(
                value: RoutineLevel.beginner,
                child: Text('Beginner'),
              ),
              const PopupMenuItem(
                value: RoutineLevel.intermediate,
                child: Text('Intermediate'),
              ),
              const PopupMenuItem(
                value: RoutineLevel.advanced,
                child: Text('Advanced'),
              ),
            ],
          ),
        ],
      ),
      body: _routines.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.list_alt,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No routines available',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _routines.length,
              itemBuilder: (context, index) {
                final routine = _routines[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    onTap: () => _showRoutineDetails(routine),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  routine.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Chip(
                                    label: Text(
                                      routine.levelDisplayName,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    backgroundColor: _getLevelColor(routine.level),
                                  ),
                                  if (_isCustomRoutine(routine)) ...[
                                    const SizedBox(width: 8),
                                    PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'delete') {
                                          _deleteCustomRoutine(routine);
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
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              if (_isCustomRoutine(routine)) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'CUSTOM',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              Expanded(
                                child: Text(
                                  routine.description,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                Icons.timer,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${routine.estimatedDuration} minutes',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.fitness_center,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${routine.exercises.length} exercises',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRoutineDialog(),
        heroTag: "routines_fab",
        child: const Icon(Icons.add),
        tooltip: 'Create Custom Routine',
      ),
    );
  }

  Color _getLevelColor(RoutineLevel level) {
    switch (level) {
      case RoutineLevel.beginner:
        return Colors.green.withOpacity(0.2);
      case RoutineLevel.intermediate:
        return Colors.orange.withOpacity(0.2);
      case RoutineLevel.advanced:
        return Colors.red.withOpacity(0.2);
    }
  }

  void _showRoutineDetails(Routine routine) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      routine.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Chip(
                    label: Text(routine.levelDisplayName),
                    backgroundColor: _getLevelColor(routine.level),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                routine.description,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.timer,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${routine.estimatedDuration} minutes',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Exercises',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: routine.exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = routine.exercises[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exercise.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${exercise.sets} sets × ${exercise.reps} reps • ${exercise.restSeconds}s rest',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                            if (exercise.description != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                exercise.description!,
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _startRoutine(routine);
                  },
                  child: const Text('Start Routine'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startRoutine(Routine routine) async {
    // Create a workout entry based on the routine
    final workout = Workout(
      type: routine.name,
      duration: routine.estimatedDuration,
      repetitions: routine.exercises.fold<int>(0, (sum, exercise) => sum + (exercise.sets * exercise.reps)),
      date: DateTime.now(),
      notes: 'Completed routine: ${routine.description}',
    );

    final dbHelper = Provider.of<DatabaseHelper>(context, listen: false);
    await dbHelper.insertWorkout(workout);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${routine.name} routine completed and logged!'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            Navigator.pushNamed(context, '/workout-log');
          },
        ),
      ),
    );
  }

  bool _isCustomRoutine(Routine routine) {
    // Check if it's a custom routine by checking if it's not one of the default routines
    // Default routines have specific names we know
    const defaultRoutineNames = [
      'Beginner Full Body',
      'Intermediate Strength', 
      'Advanced HIIT'
    ];
    return !defaultRoutineNames.contains(routine.name);
  }

  Future<void> _deleteCustomRoutine(Routine routine) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Custom Routine'),
        content: Text('Are you sure you want to delete "${routine.name}"?\n\nThis action cannot be undone.'),
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
      try {
        final dbHelper = Provider.of<DatabaseHelper>(context, listen: false);
        await dbHelper.deleteRoutine(routine.id!);
        _loadRoutines();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Custom routine deleted successfully'),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting routine: $e'),
          ),
        );
      }
    }
  }

  void _showAddRoutineDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddRoutineScreen(
          onRoutineAdded: () {
            _loadRoutines();
          },
        ),
      ),
    );
  }
}

class AddRoutineScreen extends StatefulWidget {
  final VoidCallback onRoutineAdded;

  const AddRoutineScreen({
    super.key,
    required this.onRoutineAdded,
  });

  @override
  State<AddRoutineScreen> createState() => _AddRoutineScreenState();
}

class _AddRoutineScreenState extends State<AddRoutineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  RoutineLevel _selectedLevel = RoutineLevel.beginner;
  int _estimatedDuration = 30;
  final List<Exercise> _exercises = [];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Routine'),
        actions: [
          TextButton(
            onPressed: _exercises.isEmpty ? null : _saveRoutine,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Routine Information',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Routine Name *',
                        hintText: 'e.g., My Custom Workout',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a routine name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description *',
                        hintText: 'Describe what this routine is for',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<RoutineLevel>(
                            value: _selectedLevel,
                            decoration: const InputDecoration(
                              labelText: 'Difficulty Level',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (level) {
                              if (level != null) {
                                setState(() {
                                  _selectedLevel = level;
                                });
                              }
                            },
                            items: RoutineLevel.values.map((level) {
                              return DropdownMenuItem(
                                value: level,
                                child: Text(_getLevelDisplayName(level)),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Duration (min)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            initialValue: _estimatedDuration.toString(),
                            onChanged: (value) {
                              final duration = int.tryParse(value);
                              if (duration != null && duration > 0) {
                                _estimatedDuration = duration;
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Exercises (${_exercises.length})',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        ElevatedButton.icon(
                          onPressed: _showAddExerciseDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Exercise'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_exercises.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(32),
                        child: const Column(
                          children: [
                            Icon(
                              Icons.fitness_center,
                              size: 48,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No exercises added yet',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Tap "Add Exercise" to get started',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ...List.generate(_exercises.length, (index) {
                        final exercise = _exercises[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const Icon(Icons.fitness_center),
                            title: Text(exercise.name),
                            subtitle: Text(
                              '${exercise.sets} sets × ${exercise.reps} reps • ${exercise.restSeconds}s rest',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _exercises.removeAt(index);
                                });
                              },
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLevelDisplayName(RoutineLevel level) {
    switch (level) {
      case RoutineLevel.beginner:
        return 'Beginner';
      case RoutineLevel.intermediate:
        return 'Intermediate';
      case RoutineLevel.advanced:
        return 'Advanced';
    }
  }

  void _showAddExerciseDialog() {
    final nameController = TextEditingController();
    final setsController = TextEditingController(text: '3');
    final repsController = TextEditingController(text: '10');
    final restController = TextEditingController(text: '60');
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Exercise'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Exercise Name *',
                  hintText: 'e.g., Push-ups, Squats',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: setsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Sets',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: repsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Reps',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: restController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Rest (seconds)',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'Exercise instructions or tips',
                ),
                maxLines: 2,
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
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                final exercise = Exercise(
                  name: nameController.text.trim(),
                  sets: int.tryParse(setsController.text) ?? 3,
                  reps: int.tryParse(repsController.text) ?? 10,
                  restSeconds: int.tryParse(restController.text) ?? 60,
                  description: descriptionController.text.trim().isNotEmpty
                      ? descriptionController.text.trim()
                      : null,
                );
                
                setState(() {
                  _exercises.add(exercise);
                });
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter an exercise name'),
                  ),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveRoutine() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one exercise'),
        ),
      );
      return;
    }

    final routine = Routine(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      level: _selectedLevel,
      estimatedDuration: _estimatedDuration,
      exercises: _exercises,
    );

    try {
      final dbHelper = Provider.of<DatabaseHelper>(context, listen: false);
      await dbHelper.insertRoutine(routine);
      
      widget.onRoutineAdded();
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Custom routine created successfully!'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating routine: $e'),
        ),
      );
    }
  }
}