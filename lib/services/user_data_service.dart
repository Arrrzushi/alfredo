class UserDataService {
  static final UserDataService _instance = UserDataService._internal();
  factory UserDataService() => _instance;
  UserDataService._internal();

  // User Profile Data
  String name = 'John Doe';
  int age = 28;
  double weight = 75.0; // kg
  double height = 175.0; // cm
  String gender = 'Male';
  String goal = 'Maintain Weight';
  List<String> dietaryPreferences = ['Vegetarian', 'Low Carb'];

  // Calculated values
  double get bmi {
    final heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  String get bmiCategory {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  double get bmr {
    if (gender == 'Male') {
      return 10 * weight + 6.25 * height - 5 * age + 5;
    } else {
      return 10 * weight + 6.25 * height - 5 * age - 161;
    }
  }

  double get tdee => bmr * 1.55; // Moderate activity level

  int get calorieGoal {
    switch (goal) {
      case 'Lose Weight':
        return (tdee * 0.85).toInt(); // 15% deficit
      case 'Gain Weight':
        return (tdee * 1.15).toInt(); // 15% surplus
      case 'Build Muscle':
        return (tdee * 1.1).toInt(); // 10% surplus
      default:
        return tdee.toInt(); // Maintain
    }
  }

  double get proteinGoal {
    switch (goal) {
      case 'Build Muscle':
        return weight * 2.2; // 2.2g per kg
      case 'Lose Weight':
        return weight * 2.0; // 2.0g per kg
      default:
        return weight * 1.6; // 1.6g per kg
    }
  }

  double get carbsGoal {
    final proteinCalories = proteinGoal * 4;
    final fatCalories = (calorieGoal * 0.25); // 25% from fat
    final remainingCalories = calorieGoal - proteinCalories - fatCalories;
    return remainingCalories / 4; // 4 calories per gram of carbs
  }

  double get fatGoal => (calorieGoal * 0.25) / 9; // 25% from fat, 9 cal per gram

  void updateProfile({
    String? name,
    int? age,
    double? weight,
    double? height,
    String? gender,
    String? goal,
    List<String>? dietaryPreferences,
  }) {
    if (name != null) this.name = name;
    if (age != null) this.age = age;
    if (weight != null) this.weight = weight;
    if (height != null) this.height = height;
    if (gender != null) this.gender = gender;
    if (goal != null) this.goal = goal;
    if (dietaryPreferences != null) this.dietaryPreferences = dietaryPreferences;
  }
}

