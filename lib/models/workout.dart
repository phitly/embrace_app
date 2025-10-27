class Workout {
  int? id;
  String type;
  int duration; // in minutes
  int repetitions;
  DateTime date;
  String? notes;

  Workout({
    this.id,
    required this.type,
    required this.duration,
    required this.repetitions,
    required this.date,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'duration': duration,
      'repetitions': repetitions,
      'date': date.millisecondsSinceEpoch,
      'notes': notes,
    };
  }

  factory Workout.fromMap(Map<String, dynamic> map) {
    return Workout(
      id: map['id'],
      type: map['type'],
      duration: map['duration'],
      repetitions: map['repetitions'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      notes: map['notes'],
    );
  }

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'],
      type: json['type'],
      duration: json['duration'],
      repetitions: json['repetitions'],
      date: DateTime.parse(json['date']),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'duration': duration,
      'repetitions': repetitions,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }

  @override
  String toString() {
    return 'Workout{id: $id, type: $type, duration: $duration, repetitions: $repetitions, date: $date, notes: $notes}';
  }
}