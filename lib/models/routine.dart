enum RoutineLevel { beginner, intermediate, advanced }

class Exercise {
  String name;
  int reps;
  int sets;
  int restSeconds;
  String? description;

  Exercise({
    required this.name,
    required this.reps,
    required this.sets,
    required this.restSeconds,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'reps': reps,
      'sets': sets,
      'restSeconds': restSeconds,
      'description': description,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      name: map['name'],
      reps: map['reps'],
      sets: map['sets'],
      restSeconds: map['restSeconds'],
      description: map['description'],
    );
  }
}

class Routine {
  int? id;
  String name;
  String description;
  RoutineLevel level;
  int estimatedDuration; // in minutes
  List<Exercise> exercises;
  String? imageUrl;

  Routine({
    this.id,
    required this.name,
    required this.description,
    required this.level,
    required this.estimatedDuration,
    required this.exercises,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'level': level.name,
      'estimatedDuration': estimatedDuration,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'imageUrl': imageUrl,
    };
  }

  factory Routine.fromMap(Map<String, dynamic> map) {
    return Routine(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      level: RoutineLevel.values.firstWhere((e) => e.name == map['level']),
      estimatedDuration: map['estimatedDuration'],
      exercises: (map['exercises'] as List)
          .map((e) => Exercise.fromMap(e))
          .toList(),
      imageUrl: map['imageUrl'],
    );
  }

  factory Routine.fromJson(Map<String, dynamic> json) {
    return Routine(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      level: RoutineLevel.values.firstWhere((e) => e.name == json['level']),
      estimatedDuration: json['estimatedDuration'],
      exercises: (json['exercises'] as List)
          .map((e) => Exercise.fromMap(e))
          .toList(),
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'level': level.name,
      'estimatedDuration': estimatedDuration,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'imageUrl': imageUrl,
    };
  }

  String get levelDisplayName {
    switch (level) {
      case RoutineLevel.beginner:
        return 'Beginner';
      case RoutineLevel.intermediate:
        return 'Intermediate';
      case RoutineLevel.advanced:
        return 'Advanced';
    }
  }

  @override
  String toString() {
    return 'Routine{id: $id, name: $name, description: $description, level: $level, estimatedDuration: $estimatedDuration, exercises: ${exercises.length}, imageUrl: $imageUrl}';
  }
}