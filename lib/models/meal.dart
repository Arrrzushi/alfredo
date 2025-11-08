class Meal {
  final String id;
  final String name;
  final DateTime dateTime;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final String mealType; // breakfast, lunch, dinner, snack

  Meal({
    required this.id,
    required this.name,
    required this.dateTime,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.mealType,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'dateTime': dateTime.toIso8601String(),
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'mealType': mealType,
      };

  factory Meal.fromJson(Map<String, dynamic> json) => Meal(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        dateTime: DateTime.parse(json['dateTime']),
        calories: json['calories'] ?? 0,
        protein: (json['protein'] ?? 0).toDouble(),
        carbs: (json['carbs'] ?? 0).toDouble(),
        fat: (json['fat'] ?? 0).toDouble(),
        mealType: json['mealType'] ?? 'snack',
      );
}
