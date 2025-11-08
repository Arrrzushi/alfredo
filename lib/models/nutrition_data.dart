class NutritionData {
  final DateTime date;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final int goalCalories;
  final double goalProtein;
  final double goalCarbs;
  final double goalFat;

  NutritionData({
    required this.date,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.goalCalories = 2000,
    this.goalProtein = 150,
    this.goalCarbs = 250,
    this.goalFat = 65,
  });

  double get caloriesProgress => (calories / goalCalories).clamp(0.0, 1.0);
  double get proteinProgress => (protein / goalProtein).clamp(0.0, 1.0);
  double get carbsProgress => (carbs / goalCarbs).clamp(0.0, 1.0);
  double get fatProgress => (fat / goalFat).clamp(0.0, 1.0);
}

