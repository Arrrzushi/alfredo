import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/neomorphic_container.dart';
import '../widgets/search_bar.dart';
import '../models/recipe.dart';
import 'create_recipe_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  String _selectedFilter = 'All';
  final Set<String> _favoriteRecipes = {};
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Recipe> _communityRecipes = [
    Recipe(
      id: '1',
      title: 'Paneer Spinach Curry',
      description: 'A healthy, low-carb curry made with fresh spinach and paneer. Perfect for vegetarians!',
      ingredients: ['200g Spinach', '250g Paneer', '1 Onion', '2 Tomatoes', 'Spices'],
      instructions: [
        'Heat oil in a pan and sauté onions until golden',
        'Add tomatoes and cook until soft',
        'Add spices and spinach, cook for 5 minutes',
        'Add paneer cubes and simmer for 10 minutes',
        'Serve hot with roti or rice',
      ],
      calories: 320,
      protein: 18,
      carbs: 12,
      fat: 22,
      prepTime: 15,
      cookTime: 25,
    ),
    Recipe(
      id: '2',
      title: 'Banana Oats Smoothie',
      description: 'A nutritious breakfast smoothie with banana and oats. Great for a quick morning meal!',
      ingredients: ['2 Bananas', '50g Oats', '200ml Milk', '1 tbsp Honey', 'Ice cubes'],
      instructions: [
        'Blend oats until fine powder',
        'Add bananas, milk, and honey',
        'Blend until smooth',
        'Add ice and blend again',
        'Serve chilled',
      ],
      calories: 280,
      protein: 10,
      carbs: 45,
      fat: 8,
      prepTime: 5,
      cookTime: 0,
    ),
    Recipe(
      id: '3',
      title: 'Mediterranean Quinoa Bowl',
      description: 'Fresh and healthy quinoa bowl with vegetables. Packed with protein and fiber!',
      ingredients: ['200g Quinoa', 'Cherry Tomatoes', 'Cucumber', 'Feta Cheese', 'Olive Oil'],
      instructions: [
        'Cook quinoa according to package instructions',
        'Chop vegetables into bite-sized pieces',
        'Mix quinoa with vegetables',
        'Add feta cheese and drizzle with olive oil',
        'Season with salt and pepper',
      ],
      calories: 380,
      protein: 15,
      carbs: 55,
      fat: 12,
      prepTime: 10,
      cookTime: 20,
    ),
    Recipe(
      id: '4',
      title: 'Grilled Chicken Salad',
      description: 'Light and protein-rich salad perfect for lunch. Low in carbs, high in flavor!',
      ingredients: ['200g Chicken Breast', 'Mixed Greens', 'Cherry Tomatoes', 'Cucumber', 'Olive Oil Dressing'],
      instructions: [
        'Marinate chicken with spices for 30 minutes',
        'Grill chicken until cooked through',
        'Slice chicken and arrange on bed of greens',
        'Add vegetables and drizzle with dressing',
        'Serve immediately',
      ],
      calories: 350,
      protein: 35,
      carbs: 15,
      fat: 18,
      prepTime: 10,
      cookTime: 15,
    ),
    Recipe(
      id: '5',
      title: 'Veggie Stir Fry',
      description: 'Quick and colorful vegetable stir fry. Ready in 15 minutes!',
      ingredients: ['Mixed Vegetables', 'Bell Peppers', 'Broccoli', 'Carrots', 'Soy Sauce'],
      instructions: [
        'Heat oil in a wok or large pan',
        'Add vegetables and stir-fry for 5 minutes',
        'Add soy sauce and seasonings',
        'Cook for another 5 minutes until tender',
        'Serve hot with rice or noodles',
      ],
      calories: 180,
      protein: 8,
      carbs: 25,
      fat: 6,
      prepTime: 10,
      cookTime: 10,
    ),
  ];

  List<Recipe> get _filteredRecipes {
    var recipes = _communityRecipes;
    
    if (_isSearching && _searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      recipes = recipes.where((recipe) {
        return recipe.title.toLowerCase().contains(query) ||
               recipe.description.toLowerCase().contains(query) ||
               recipe.ingredients.any((ing) => ing.toLowerCase().contains(query));
      }).toList();
    }

    switch (_selectedFilter) {
      case 'Top Rated':
        return recipes..sort((a, b) => b.calories.compareTo(a.calories));
      case 'Most Starred':
        return recipes..sort((a, b) => _getStarCount(b.id).compareTo(_getStarCount(a.id)));
      case 'Recent':
        return recipes.reversed.toList();
      default:
        return recipes;
    }
  }

  int _getStarCount(String recipeId) {
    // Mock star counts
    final counts = {'1': 1250, '2': 890, '3': 650, '4': 420, '5': 320};
    return counts[recipeId] ?? 0;
  }

  double _getRating(String recipeId) {
    // Mock ratings
    final ratings = {'1': 4.8, '2': 4.6, '3': 4.7, '4': 4.5, '5': 4.4};
    return ratings[recipeId] ?? 4.5;
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
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
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search recipes...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: AppTheme.gray400),
                ),
                style: Theme.of(context).textTheme.titleMedium,
                onChanged: (_) => setState(() {}),
              )
            : const Text('Community'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close_rounded : Icons.search_rounded),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                }
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Search Bar
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 300),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.9 + (0.1 * value),
                    child: Opacity(
                      opacity: value,
                      child: child,
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SearchBarWidget(
                    controller: _searchController,
                    showPrefixIcon: false, // Remove duplicate icon since app bar has search
                    onChanged: (value) {
                      setState(() {
                        _isSearching = value.isNotEmpty;
                      });
                    },
                  ),
                ),
              ),

              // Filter Chips
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('All'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Top Rated'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Most Starred'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Recent'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Low Cal'),
                  ],
                ),
                  ),
                ),
              ),

              // Recipes List
              Expanded(
                child: _filteredRecipes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 64,
                            color: AppTheme.gray400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No recipes found',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try a different search term',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.gray600,
                                ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredRecipes.length,
                      itemBuilder: (context, index) {
                        final recipe = _filteredRecipes[index];
                        final isFavorite = _favoriteRecipes.contains(recipe.id);
                        final starCount = _getStarCount(recipe.id);
                        final rating = _getRating(recipe.id);

                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: Duration(milliseconds: 200 + (index * 50)),
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(0, 30 * (1 - value)),
                              child: Opacity(
                                opacity: value,
                                child: child,
                              ),
                            );
                          },
                          child: NeomorphicContainer(
                          padding: EdgeInsets.zero,
                          margin: const EdgeInsets.only(bottom: 16),
                          onTap: () {
                            _showRecipeDetails(recipe, starCount, rating);
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Recipe Image Placeholder
                              Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryOrange.withValues(alpha: 0.1),
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Center(
                                      child: Icon(
                                        Icons.restaurant_menu_rounded,
                                        size: 64,
                                        color: AppTheme.primaryOrange,
                                      ),
                                    ),
                                    Positioned(
                                      top: 12,
                                      right: 12,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryOrange,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.star_rounded,
                                              color: Colors.white,
                                              size: 14,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              rating.toStringAsFixed(1),
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 12,
                                      left: 12,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.5),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.local_fire_department_rounded,
                                              color: Colors.white,
                                              size: 14,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${recipe.calories} cal',
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            recipe.title,
                                            style: Theme.of(context).textTheme.titleLarge,
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            isFavorite
                                                ? Icons.favorite_rounded
                                                : Icons.favorite_border_rounded,
                                            color: isFavorite ? Colors.red : AppTheme.gray600,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              if (isFavorite) {
                                                _favoriteRecipes.remove(recipe.id);
                                              } else {
                                                _favoriteRecipes.add(recipe.id);
                                              }
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      recipe.description,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: AppTheme.gray600,
                                          ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.timer_rounded,
                                          size: 16,
                                          color: AppTheme.gray600,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${recipe.prepTime + recipe.cookTime} min',
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                        const SizedBox(width: 16),
                                        Icon(
                                          Icons.people_rounded,
                                          size: 16,
                                          color: AppTheme.gray600,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${(starCount / 1000).toStringAsFixed(1)}k',
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                        const SizedBox(width: 16),
                                        Icon(
                                          Icons.star_rounded,
                                          size: 16,
                                          color: Colors.amber,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          starCount.toString(),
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryOrange.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            'View Recipe',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  color: AppTheme.primaryOrange,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        );
                      },
                    ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateRecipeScreen(),
            ),
          ).then((_) {
            setState(() {}); // Refresh if recipe was added
          });
        },
        backgroundColor: AppTheme.primaryOrange,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Post Recipe'),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = label;
        });
      },
      selectedColor: AppTheme.primaryOrange.withValues(alpha: 0.2),
      checkmarkColor: AppTheme.primaryOrange,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryOrange : AppTheme.gray700,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  void _showRecipeDetails(Recipe recipe, int starCount, double rating) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.gray400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            recipe.title,
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _favoriteRecipes.contains(recipe.id)
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: _favoriteRecipes.contains(recipe.id) ? Colors.red : AppTheme.gray600,
                          ),
                          onPressed: () {
                            setState(() {
                              if (_favoriteRecipes.contains(recipe.id)) {
                                _favoriteRecipes.remove(recipe.id);
                              } else {
                                _favoriteRecipes.add(recipe.id);
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$rating ($starCount stars)',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.people_rounded,
                          size: 16,
                          color: AppTheme.gray600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${(starCount / 1000).toStringAsFixed(1)}k tried',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      recipe.description,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.gray600,
                          ),
                    ),
                    const SizedBox(height: 24),
                    // Nutrition Info
                    NeomorphicContainer(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildNutritionChip('Calories', '${recipe.calories}'),
                          _buildNutritionChip('Protein', '${recipe.protein}g'),
                          _buildNutritionChip('Carbs', '${recipe.carbs}g'),
                          _buildNutritionChip('Fat', '${recipe.fat}g'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Icon(Icons.timer_rounded, size: 18, color: AppTheme.gray600),
                        const SizedBox(width: 8),
                        Text(
                          'Prep: ${recipe.prepTime} min | Cook: ${recipe.cookTime} min',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Ingredients',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    ...recipe.ingredients.map((ingredient) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.circle_rounded,
                                size: 8,
                                color: AppTheme.primaryOrange,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  ingredient,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 24),
                    Text(
                      'Instructions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    ...recipe.instructions.asMap().entries.map((entry) {
                      final index = entry.key + 1;
                      final instruction = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryOrange,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Text(
                                  '$index',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                instruction,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // Action Buttons - Fixed to bottom
            Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom,
                top: 12,
                left: 20,
                right: 20,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    offset: const Offset(0, -2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            if (_favoriteRecipes.contains(recipe.id)) {
                              _favoriteRecipes.remove(recipe.id);
                            } else {
                              _favoriteRecipes.add(recipe.id);
                            }
                          });
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          _favoriteRecipes.contains(recipe.id)
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                        ),
                        label: const Text('Save Recipe'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryOrange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Share recipe
                        },
                        icon: const Icon(Icons.share_rounded),
                        label: const Text('Share'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryOrange,
                          side: BorderSide(color: AppTheme.primaryOrange),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionChip(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.primaryOrange,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
