import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import '../theme/app_theme.dart';
import '../widgets/neomorphic_container.dart';
import '../widgets/voice_button.dart';
import '../widgets/search_bar.dart';
import '../models/recipe.dart';
import '../services/user_data_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  final TextEditingController _searchController = TextEditingController();
  bool _isListening = false;
  String _transcript = '';
  String _alfredoResponse = '';
  bool _isProcessing = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Recipe> _featuredRecipes = [
    Recipe(
      id: '1',
      title: 'Paneer Spinach Curry',
      description: 'A healthy, low-carb curry made with fresh spinach and paneer',
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
      description: 'A nutritious breakfast smoothie with banana and oats',
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
      title: 'Grilled Chicken Salad',
      description: 'Light and protein-rich salad perfect for lunch',
      ingredients: ['200g Chicken', 'Mixed Greens', 'Cherry Tomatoes', 'Cucumber', 'Dressing'],
      instructions: [
        'Marinate chicken with spices',
        'Grill chicken until cooked',
        'Slice and arrange on greens',
        'Add vegetables and dressing',
        'Serve immediately',
      ],
      calories: 350,
      protein: 35,
      carbs: 15,
      fat: 18,
      prepTime: 10,
      cookTime: 15,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
    _initializeTts();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  Future<void> _initializeSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() {
            _isListening = false;
          });
        }
      },
      onError: (error) {
        setState(() {
          _isListening = false;
          _alfredoResponse = 'Sorry, I had trouble understanding. Please try again.';
        });
      },
    );
    if (!available) {
      setState(() {
        _alfredoResponse = 'Speech recognition not available on this device.';
      });
    }
  }

  Future<void> _initializeTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() {
          _isListening = true;
          _transcript = '';
          _alfredoResponse = '';
        });
        await _speech.listen(
          onResult: (result) {
            setState(() {
              _transcript = result.recognizedWords;
            });
            if (result.finalResult) {
              _processVoiceCommand(result.recognizedWords);
            }
          },
        );
      }
    } else {
      _stopListening();
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  Future<void> _processVoiceCommand(String command) async {
    setState(() {
      _isProcessing = true;
    });

    await Future.delayed(const Duration(seconds: 1));
    String response = _generateMockResponse(command);
    setState(() {
      _alfredoResponse = response;
      _isProcessing = false;
    });

    await _tts.speak(response);
  }

  String _generateMockResponse(String command) {
    final lowerCommand = command.toLowerCase();
    
    if (lowerCommand.contains('hello') || lowerCommand.contains('hi')) {
      return 'Hello! I\'m Alfredo, your AI nutrition assistant. How can I help you today?';
    } else if (lowerCommand.contains('recipe') || lowerCommand.contains('cook')) {
      return 'I\'d be happy to suggest a recipe! What ingredients would you like to use?';
    } else if (lowerCommand.contains('pantry')) {
      return 'I can help you manage your pantry. Check the Smart Pantry section for details.';
    } else if (lowerCommand.contains('nutrition')) {
      return 'I can help you track your nutrition. Check the Diet & Nutrition section for your daily intake.';
    } else {
      return 'I heard: "$command". I\'m here to help with your nutrition needs.';
    }
  }

  void _handleSearch() {
    if (_searchController.text.isNotEmpty) {
      // Handle search - can navigate to search results or filter recipes
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Searching for: ${_searchController.text}'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = UserDataService();
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with Logo and Notification
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Alfredo Logo
                  Text(
                    'Alfredo',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: AppTheme.primaryOrange,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                  ),
                  // Notification Bell
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined),
                        color: AppTheme.gray700,
                        onPressed: () {
                          // Show notifications
                        },
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryOrange,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await Future.delayed(const Duration(seconds: 1));
                  setState(() {});
                },
                color: AppTheme.primaryOrange,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome Section
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 250),
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
                                  'Welcome back, ${userData.name.split(' ').first}! 👋',
                                  style: Theme.of(context).textTheme.headlineMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Ready to cook something amazing today?',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: AppTheme.gray600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Search Bar
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 300),
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: 0.8 + (0.2 * value),
                              child: Opacity(
                                opacity: value,
                                child: child,
                              ),
                            );
                          },
                          child: SearchBarWidget(
                            controller: _searchController,
                            onTap: _handleSearch,
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Voice Interface
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 400),
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: 0.7 + (0.3 * value),
                              child: Opacity(
                                opacity: value,
                                child: child,
                              ),
                            );
                          },
                          child: Center(
                            child: Column(
                              children: [
                                VoiceButton(
                                  isListening: _isListening,
                                  onTap: _startListening,
                                  size: 100,
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  _isListening
                                      ? 'Listening...'
                                      : _isProcessing
                                          ? 'Processing...'
                                          : 'Tap to talk to Alfredo',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Transcript & Response
                        if (_transcript.isNotEmpty || _alfredoResponse.isNotEmpty) ...[
                          if (_transcript.isNotEmpty)
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 200),
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'You said:',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: AppTheme.gray600,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _transcript,
                                      style: Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (_alfredoResponse.isNotEmpty)
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 200),
                              builder: (context, value, child) {
                                return Transform.translate(
                                  offset: Offset(20 * (1 - value), 0),
                                  child: Opacity(
                                    opacity: value,
                                    child: child,
                                  ),
                                );
                              },
                              child: NeomorphicContainer(
                                padding: const EdgeInsets.all(16),
                                color: AppTheme.accentYellow.withValues(alpha: 0.3),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.auto_awesome_rounded,
                                          color: AppTheme.primaryOrange,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Alfredo:',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: AppTheme.primaryOrange,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _alfredoResponse,
                                      style: Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          const SizedBox(height: 30),
                        ],

                        // AI Recipes Section
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 250),
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'AI Recipes',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // Generate new recipe
                                    },
                                    child: const Text('Generate New'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 200,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _featuredRecipes.length,
                                  itemBuilder: (context, index) {
                                    final recipe = _featuredRecipes[index];
                                    return TweenAnimationBuilder<double>(
                                      tween: Tween(begin: 0.0, end: 1.0),
                                      duration: Duration(milliseconds: 200 + (index * 50)),
                                      builder: (context, value, child) {
                                        return Transform.scale(
                                          scale: 0.8 + (0.2 * value),
                                          child: Opacity(
                                            opacity: value,
                                            child: child,
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: 280,
                                        margin: const EdgeInsets.only(right: 16),
                                        child: NeomorphicContainer(
                                          padding: EdgeInsets.zero,
                                          onTap: () {
                                            _showRecipeDetails(recipe);
                                          },
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                height: 120,
                                                decoration: BoxDecoration(
                                                  color: AppTheme.primaryOrange.withValues(alpha: 0.1),
                                                  borderRadius: const BorderRadius.vertical(
                                                    top: Radius.circular(20),
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Icon(
                                                    Icons.restaurant_menu_rounded,
                                                    size: 48,
                                                    color: AppTheme.primaryOrange,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(12),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      recipe.title,
                                                      style: Theme.of(context).textTheme.titleMedium,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.local_fire_department_rounded,
                                                          size: 14,
                                                          color: AppTheme.primaryOrange,
                                                        ),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          '${recipe.calories} cal',
                                                          style: Theme.of(context).textTheme.bodySmall,
                                                        ),
                                                        const SizedBox(width: 12),
                                                        Icon(
                                                          Icons.timer_rounded,
                                                          size: 14,
                                                          color: AppTheme.gray600,
                                                        ),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          '${recipe.prepTime + recipe.cookTime} min',
                                                          style: Theme.of(context).textTheme.bodySmall,
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Quick Stats
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
                          child: Row(
                            children: [
                              Expanded(
                                child: NeomorphicContainer(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      Text(
                                        '${userData.calorieGoal}',
                                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                              color: AppTheme.primaryOrange,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      Text(
                                        'Cal Goal',
                                        style: Theme.of(context).textTheme.bodySmall,
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: NeomorphicContainer(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      Text(
                                        userData.bmi.toStringAsFixed(1),
                                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      Text(
                                        'BMI',
                                        style: Theme.of(context).textTheme.bodySmall,
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRecipeDetails(Recipe recipe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
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
                    Text(
                      recipe.title,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      recipe.description,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.gray600,
                          ),
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _speech.stop();
    _tts.stop();
    super.dispose();
  }
}
