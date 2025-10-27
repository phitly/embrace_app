import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/models.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'fitness_tracker.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create workouts table
    await db.execute('''
      CREATE TABLE workouts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        duration INTEGER NOT NULL,
        repetitions INTEGER NOT NULL,
        date INTEGER NOT NULL,
        notes TEXT
      )
    ''');

    // Create calorie entries table
    await db.execute('''
      CREATE TABLE calorie_entries(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        foodName TEXT NOT NULL,
        calories INTEGER NOT NULL,
        date INTEGER NOT NULL,
        quantity REAL,
        unit TEXT,
        notes TEXT
      )
    ''');

    // Create routines table
    await db.execute('''
      CREATE TABLE routines(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        level TEXT NOT NULL,
        estimatedDuration INTEGER NOT NULL,
        exercises TEXT NOT NULL,
        imageUrl TEXT
      )
    ''');

    // Insert default routines
    await _insertDefaultRoutines(db);
  }

  Future<void> _insertDefaultRoutines(Database db) async {
    final beginnerRoutine = Routine(
      name: 'Beginner Full Body',
      description: 'A simple full-body workout perfect for beginners',
      level: RoutineLevel.beginner,
      estimatedDuration: 30,
      exercises: [
        Exercise(name: 'Push-ups', reps: 10, sets: 3, restSeconds: 60, description: 'Standard push-ups'),
        Exercise(name: 'Squats', reps: 15, sets: 3, restSeconds: 60, description: 'Bodyweight squats'),
        Exercise(name: 'Planks', reps: 30, sets: 3, restSeconds: 60, description: 'Hold plank position for 30 seconds'),
        Exercise(name: 'Jumping Jacks', reps: 20, sets: 3, restSeconds: 45, description: 'Standard jumping jacks'),
      ],
    );

    final intermediateRoutine = Routine(
      name: 'Intermediate Strength',
      description: 'Build strength with this intermediate workout',
      level: RoutineLevel.intermediate,
      estimatedDuration: 45,
      exercises: [
        Exercise(name: 'Push-ups', reps: 20, sets: 4, restSeconds: 60, description: 'Standard or diamond push-ups'),
        Exercise(name: 'Squats', reps: 25, sets: 4, restSeconds: 60, description: 'Bodyweight or jump squats'),
        Exercise(name: 'Lunges', reps: 15, sets: 4, restSeconds: 60, description: 'Alternating lunges'),
        Exercise(name: 'Planks', reps: 60, sets: 3, restSeconds: 60, description: 'Hold plank position for 60 seconds'),
        Exercise(name: 'Burpees', reps: 10, sets: 3, restSeconds: 90, description: 'Full burpees'),
        Exercise(name: 'Mountain Climbers', reps: 30, sets: 3, restSeconds: 60, description: 'Fast mountain climbers'),
      ],
    );

    final advancedRoutine = Routine(
      name: 'Advanced HIIT',
      description: 'High-intensity workout for advanced fitness enthusiasts',
      level: RoutineLevel.advanced,
      estimatedDuration: 60,
      exercises: [
        Exercise(name: 'Burpees', reps: 20, sets: 5, restSeconds: 60, description: 'Full burpees with jump'),
        Exercise(name: 'Jump Squats', reps: 30, sets: 5, restSeconds: 60, description: 'Explosive jump squats'),
        Exercise(name: 'Push-up to T', reps: 15, sets: 4, restSeconds: 60, description: 'Push-up with T rotation'),
        Exercise(name: 'Plank to Push-up', reps: 12, sets: 4, restSeconds: 60, description: 'Transition from plank to push-up'),
        Exercise(name: 'Mountain Climbers', reps: 50, sets: 4, restSeconds: 45, description: 'Fast mountain climbers'),
        Exercise(name: 'Jump Lunges', reps: 20, sets: 4, restSeconds: 60, description: 'Alternating jump lunges'),
        Exercise(name: 'Russian Twists', reps: 40, sets: 4, restSeconds: 45, description: 'Core twisting exercise'),
      ],
    );

    await db.insert('routines', beginnerRoutine.toMap()..['exercises'] = jsonEncode(beginnerRoutine.exercises.map((e) => e.toMap()).toList()));
    await db.insert('routines', intermediateRoutine.toMap()..['exercises'] = jsonEncode(intermediateRoutine.exercises.map((e) => e.toMap()).toList()));
    await db.insert('routines', advancedRoutine.toMap()..['exercises'] = jsonEncode(advancedRoutine.exercises.map((e) => e.toMap()).toList()));
  }

  // Workout CRUD operations
  Future<int> insertWorkout(Workout workout) async {
    final db = await database;
    return await db.insert('workouts', workout.toMap());
  }

  Future<List<Workout>> getWorkouts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('workouts', orderBy: 'date DESC');
    return List.generate(maps.length, (i) => Workout.fromMap(maps[i]));
  }

  Future<List<Workout>> getWorkoutsForDateRange(DateTime start, DateTime end) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'workouts',
      where: 'date >= ? AND date <= ?',
      whereArgs: [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Workout.fromMap(maps[i]));
  }

  Future<List<Workout>> getTodayWorkouts() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return getWorkoutsForDateRange(startOfDay, endOfDay);
  }

  Future<int> updateWorkout(Workout workout) async {
    final db = await database;
    return await db.update(
      'workouts',
      workout.toMap(),
      where: 'id = ?',
      whereArgs: [workout.id],
    );
  }

  Future<int> deleteWorkout(int id) async {
    final db = await database;
    return await db.delete(
      'workouts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Calorie Entry CRUD operations
  Future<int> insertCalorieEntry(CalorieEntry entry) async {
    final db = await database;
    return await db.insert('calorie_entries', entry.toMap());
  }

  Future<List<CalorieEntry>> getCalorieEntries() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('calorie_entries', orderBy: 'date DESC');
    return List.generate(maps.length, (i) => CalorieEntry.fromMap(maps[i]));
  }

  Future<List<CalorieEntry>> getCalorieEntriesForDateRange(DateTime start, DateTime end) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'calorie_entries',
      where: 'date >= ? AND date <= ?',
      whereArgs: [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => CalorieEntry.fromMap(maps[i]));
  }

  Future<List<CalorieEntry>> getTodayCalorieEntries() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return getCalorieEntriesForDateRange(startOfDay, endOfDay);
  }

  Future<int> getTodayTotalCalories() async {
    final entries = await getTodayCalorieEntries();
    return entries.fold<int>(0, (sum, entry) => sum + entry.calories);
  }

  Future<int> updateCalorieEntry(CalorieEntry entry) async {
    final db = await database;
    return await db.update(
      'calorie_entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> deleteCalorieEntry(int id) async {
    final db = await database;
    return await db.delete(
      'calorie_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Routine CRUD operations
  Future<int> insertRoutine(Routine routine) async {
    final db = await database;
    final map = routine.toMap();
    map['exercises'] = jsonEncode(routine.exercises.map((e) => e.toMap()).toList());
    return await db.insert('routines', map);
  }

  Future<List<Routine>> getRoutines() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('routines', orderBy: 'level, name');
    return List.generate(maps.length, (i) {
      final map = Map<String, dynamic>.from(maps[i]);
      map['exercises'] = jsonDecode(map['exercises']) as List;
      return Routine.fromMap(map);
    });
  }

  Future<List<Routine>> getRoutinesByLevel(RoutineLevel level) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'routines',
      where: 'level = ?',
      whereArgs: [level.name],
      orderBy: 'name',
    );
    return List.generate(maps.length, (i) {
      final map = Map<String, dynamic>.from(maps[i]);
      map['exercises'] = jsonDecode(map['exercises']) as List;
      return Routine.fromMap(map);
    });
  }

  Future<int> updateRoutine(Routine routine) async {
    final db = await database;
    final map = routine.toMap();
    map['exercises'] = jsonEncode(routine.exercises.map((e) => e.toMap()).toList());
    return await db.update(
      'routines',
      map,
      where: 'id = ?',
      whereArgs: [routine.id],
    );
  }

  Future<int> deleteRoutine(int id) async {
    final db = await database;
    return await db.delete(
      'routines',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Analytics methods
  Future<Map<String, int>> getWeeklyWorkoutCounts() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    final workouts = await getWorkoutsForDateRange(startOfWeek, endOfWeek);
    
    final Map<String, int> counts = {};
    for (int i = 0; i < 7; i++) {
      final day = startOfWeek.add(Duration(days: i));
      final dayKey = '${day.day}/${day.month}';
      counts[dayKey] = 0;
    }
    
    for (final workout in workouts) {
      final dayKey = '${workout.date.day}/${workout.date.month}';
      counts[dayKey] = (counts[dayKey] ?? 0) + 1;
    }
    
    return counts;
  }

  Future<Map<String, int>> getWeeklyCalorieCounts() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    final entries = await getCalorieEntriesForDateRange(startOfWeek, endOfWeek);
    
    final Map<String, int> counts = {};
    for (int i = 0; i < 7; i++) {
      final day = startOfWeek.add(Duration(days: i));
      final dayKey = '${day.day}/${day.month}';
      counts[dayKey] = 0;
    }
    
    for (final entry in entries) {
      final dayKey = '${entry.date.day}/${entry.date.month}';
      counts[dayKey] = (counts[dayKey] ?? 0) + entry.calories;
    }
    
    return counts;
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}