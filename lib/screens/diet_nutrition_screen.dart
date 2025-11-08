import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../widgets/neomorphic_container.dart';
import '../models/meal.dart';
import '../services/user_data_service.dart';

class DietNutritionScreen extends StatefulWidget {
  const DietNutritionScreen({super.key});

  @override
  State<DietNutritionScreen> createState() => _DietNutritionScreenState();
}

class _DietNutritionScreenState extends State<DietNutritionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final userData = UserDataService();

  final List<Meal> _todayMeals = [
    Meal(
      id: '1',
      name: 'Banana Oats Smoothie',
      dateTime: DateTime.now().subtract(const Duration(hours: 3)),
      calories: 280,
      protein: 10,
      carbs: 45,
      fat: 8,
      mealType: 'breakfast',
    ),
    Meal(
      id: '2',
      name: 'Paneer Spinach Curry',
      dateTime: DateTime.now().subtract(const Duration(hours: 1)),
      calories: 320,
      protein: 18,
      carbs: 12,
      fat: 22,
      mealType: 'lunch',
    ),
    Meal(
      id: '3',
      name: 'Grilled Chicken Salad',
      dateTime: DateTime.now().add(const Duration(hours: 2)),
      calories: 350,
      protein: 35,
      carbs: 15,
      fat: 18,
      mealType: 'dinner',
    ),
    Meal(
      id: '4',
      name: 'Apple with Almonds',
      dateTime: DateTime.now().subtract(const Duration(hours: 5)),
      calories: 150,
      protein: 4,
      carbs: 20,
      fat: 8,
      mealType: 'snack',
    ),
  ];

  int get _totalCalories => _todayMeals.fold(0, (sum, meal) => sum + meal.calories);
  double get _totalProtein => _todayMeals.fold(0.0, (sum, meal) => sum + meal.protein);
  double get _totalCarbs => _todayMeals.fold(0.0, (sum, meal) => sum + meal.carbs);
  double get _totalFat => _todayMeals.fold(0.0, (sum, meal) => sum + meal.fat);
  double get _totalFiber => 28.0;
  double get _totalSugar => 48.0;
  double get _totalSodium => 1250.0;
  double get _totalWater => 1800.0; // ml

  int get _calorieGoal => userData.calorieGoal;
  double get _proteinGoal => userData.proteinGoal;
  double get _carbsGoal => userData.carbsGoal;
  double get _fatGoal => userData.fatGoal;
  final double _fiberGoal = 30;
  final double _sugarLimit = 50;
  final double _waterGoal = 2625; // ml (35ml per kg for 75kg)

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diet & Nutrition'),
        elevation: 0,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 1));
            setState(() {});
          },
          color: AppTheme.primaryOrange,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Health Stats Overview
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 600),
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: Opacity(
                          opacity: value,
                          child: child,
                        ),
                      );
                    },
                    child: NeomorphicContainer(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Health Overview',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'BMI',
                                  userData.bmi.toStringAsFixed(1),
                                  userData.bmiCategory,
                                  _getBmiColor(userData.bmi),
                                  Icons.monitor_weight_rounded,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  'BMR',
                                  '${userData.bmr.toInt()}',
                                  'cal/day',
                                  AppTheme.primaryOrange,
                                  Icons.local_fire_department_rounded,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'TDEE',
                                  '${userData.tdee.toInt()}',
                                  'cal/day',
                                  Colors.blue,
                                  Icons.trending_up_rounded,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  'Weight',
                                  '${userData.weight.toInt()}',
                                  'kg',
                                  AppTheme.gray700,
                                  Icons.scale_rounded,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Daily Summary Card
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 300),
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: Opacity(
                          opacity: value,
                          child: child,
                        ),
                      );
                    },
                    child: NeomorphicContainer(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Today\'s Summary',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.gray600,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _buildProgressCard(
                            'Calories',
                            _totalCalories,
                            _calorieGoal,
                            AppTheme.primaryOrange,
                            'cal',
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: _buildMacroCard(
                                  'Protein',
                                  _totalProtein.toInt(),
                                  _proteinGoal.toInt(),
                                  Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildMacroCard(
                                  'Carbs',
                                  _totalCarbs.toInt(),
                                  _carbsGoal.toInt(),
                                  Colors.green,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildMacroCard(
                                  'Fat',
                                  _totalFat.toInt(),
                                  _fatGoal.toInt(),
                                  Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Additional Nutrients
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 350),
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: Opacity(
                          opacity: value,
                          child: child,
                        ),
                      );
                    },
                    child: NeomorphicContainer(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Additional Nutrients',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          _buildNutrientRow('Fiber', '${_totalFiber.toInt()}g', '${_fiberGoal.toInt()}g', _totalFiber / _fiberGoal, Colors.purple),
                          const SizedBox(height: 12),
                          _buildNutrientRow('Sugar', '${_totalSugar.toInt()}g', '${_sugarLimit.toInt()}g max', _totalSugar / _sugarLimit, Colors.red),
                          const SizedBox(height: 12),
                          _buildNutrientRow('Sodium', '${_totalSodium.toInt()}mg', '2300mg max', _totalSodium / 2300, Colors.blue),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Water Intake
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 400),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: 0.9 + (0.1 * value),
                        child: Opacity(
                          opacity: value,
                          child: child,
                        ),
                      );
                    },
                    child: NeomorphicContainer(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.water_drop_rounded, color: Colors.blue, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Water Intake',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                ],
                              ),
                              Text(
                                '${_totalWater.toInt()} / ${_waterGoal.toInt()} ml',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppTheme.gray600,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: (_totalWater / _waterGoal).clamp(0.0, 1.0),
                              backgroundColor: Colors.blue.withValues(alpha: 0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                              minHeight: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Macro Breakdown Chart
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 450),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: 0.8 + (0.2 * value),
                        child: Opacity(
                          opacity: value,
                          child: child,
                        ),
                      );
                    },
                    child: NeomorphicContainer(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Macro Breakdown',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 220,
                            child: Row(
                              children: [
                                Expanded(
                                  child: PieChart(
                                    PieChartData(
                                      sections: [
                                        PieChartSectionData(
                                          value: _totalProtein * 4,
                                          color: Colors.blue,
                                          title: '${(_totalProtein * 4 / _totalCalories * 100).toStringAsFixed(0)}%',
                                          radius: 50,
                                          titleStyle: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        PieChartSectionData(
                                          value: _totalCarbs * 4,
                                          color: Colors.green,
                                          title: '${(_totalCarbs * 4 / _totalCalories * 100).toStringAsFixed(0)}%',
                                          radius: 50,
                                          titleStyle: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        PieChartSectionData(
                                          value: _totalFat * 9,
                                          color: Colors.orange,
                                          title: '${(_totalFat * 9 / _totalCalories * 100).toStringAsFixed(0)}%',
                                          radius: 50,
                                          titleStyle: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                      sectionsSpace: 2,
                                      centerSpaceRadius: 50,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildLegendItem('Protein', Colors.blue, _totalProtein.toInt()),
                                      const SizedBox(height: 12),
                                      _buildLegendItem('Carbs', Colors.green, _totalCarbs.toInt()),
                                      const SizedBox(height: 12),
                                      _buildLegendItem('Fat', Colors.orange, _totalFat.toInt()),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Today's Meals
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 600),
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: Opacity(
                          opacity: value,
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Today\'s Meals',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        ..._todayMeals.asMap().entries.map((entry) {
                          final index = entry.key;
                          final meal = entry.value;
                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: Duration(milliseconds: 200 + (index * 50)),
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(-20 * (1 - value), 0),
                                child: Opacity(
                                  opacity: value,
                                  child: child,
                                ),
                              );
                            },
                            child: NeomorphicContainer(
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryOrange.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      _getMealIcon(meal.mealType),
                                      color: AppTheme.primaryOrange,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          meal.name,
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _formatMealType(meal.mealType),
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: AppTheme.gray600,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${meal.calories} cal',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              color: AppTheme.primaryOrange,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      Text(
                                        'P:${meal.protein.toInt()}g C:${meal.carbs.toInt()}g F:${meal.fat.toInt()}g',
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddMealDialog();
        },
        backgroundColor: AppTheme.primaryOrange,
        icon: const Icon(Icons.add),
        label: const Text('Log Meal'),
      ),
    );
  }

  Color _getBmiColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  Widget _buildStatCard(String label, String value, String subtitle, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.gray600,
                  fontSize: 10,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(
    String label,
    int current,
    int goal,
    Color color,
    String unit,
  ) {
    final progress = (current / goal).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              '$current / $goal $unit',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.gray600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 12,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${(progress * 100).toStringAsFixed(0)}% of daily goal',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.gray600,
              ),
        ),
      ],
    );
  }

  Widget _buildMacroCard(
    String label,
    int current,
    int goal,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          '$current',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          'of $goal g',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildNutrientRow(String label, String current, String goal, double progress, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Row(
          children: [
            Text(
              current,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            Text(
              ' / $goal',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.gray600,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, int value) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ${value}g',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  IconData _getMealIcon(String mealType) {
    switch (mealType) {
      case 'breakfast':
        return Icons.wb_sunny_rounded;
      case 'lunch':
        return Icons.lunch_dining_rounded;
      case 'dinner':
        return Icons.dinner_dining_rounded;
      default:
        return Icons.fastfood_rounded;
    }
  }

  String _formatMealType(String mealType) {
    return mealType[0].toUpperCase() + mealType.substring(1);
  }

  void _showAddMealDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Meal'),
        content: const Text('Use voice commands or manual entry to log your meals. This feature will be available soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
