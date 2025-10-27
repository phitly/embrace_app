class CalorieEntry {
  int? id;
  String foodName;
  int calories;
  DateTime date;
  double? quantity; // optional quantity (e.g., 100g, 1 cup)
  String? unit; // unit of measurement
  String? notes;

  CalorieEntry({
    this.id,
    required this.foodName,
    required this.calories,
    required this.date,
    this.quantity,
    this.unit,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'foodName': foodName,
      'calories': calories,
      'date': date.millisecondsSinceEpoch,
      'quantity': quantity,
      'unit': unit,
      'notes': notes,
    };
  }

  factory CalorieEntry.fromMap(Map<String, dynamic> map) {
    return CalorieEntry(
      id: map['id'],
      foodName: map['foodName'],
      calories: map['calories'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      quantity: map['quantity']?.toDouble(),
      unit: map['unit'],
      notes: map['notes'],
    );
  }

  factory CalorieEntry.fromJson(Map<String, dynamic> json) {
    return CalorieEntry(
      id: json['id'],
      foodName: json['foodName'],
      calories: json['calories'],
      date: DateTime.parse(json['date']),
      quantity: json['quantity']?.toDouble(),
      unit: json['unit'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'foodName': foodName,
      'calories': calories,
      'date': date.toIso8601String(),
      'quantity': quantity,
      'unit': unit,
      'notes': notes,
    };
  }

  @override
  String toString() {
    return 'CalorieEntry{id: $id, foodName: $foodName, calories: $calories, date: $date, quantity: $quantity, unit: $unit, notes: $notes}';
  }
}