class Recipe {
  final String id;
  final String title;
  final String description;
  final List<String> ingredients;
  final List<String> instructions;
  final int calories;
  final double? protein;
  final double? carbs;
  final double? fat;
  final String? imageUrl;
  final int prepTime;
  final int cookTime;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.calories,
    this.protein,
    this.carbs,
    this.fat,
    this.imageUrl,
    this.prepTime = 0,
    this.cookTime = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'ingredients': ingredients,
        'instructions': instructions,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'imageUrl': imageUrl,
        'prepTime': prepTime,
        'cookTime': cookTime,
      };

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        ingredients: List<String>.from(json['ingredients'] ?? []),
        instructions: List<String>.from(json['instructions'] ?? []),
        calories: json['calories'] ?? 0,
        protein: json['protein']?.toDouble(),
        carbs: json['carbs']?.toDouble(),
        fat: json['fat']?.toDouble(),
        imageUrl: json['imageUrl'],
        prepTime: json['prepTime'] ?? 0,
        cookTime: json['cookTime'] ?? 0,
      );
}
