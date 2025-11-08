import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/neomorphic_container.dart';
import '../services/user_data_service.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final userData = UserDataService();
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  String _selectedGoal = 'Maintain Weight';
  List<String> _dietaryPreferences = [];
  bool _isEditing = false;

  final List<String> _goals = [
    'Lose Weight',
    'Maintain Weight',
    'Gain Weight',
    'Build Muscle',
  ];

  final List<String> _availablePreferences = [
    'Vegetarian',
    'Vegan',
    'Gluten-Free',
    'Dairy-Free',
    'Low Carb',
    'Keto',
    'Paleo',
    'Halal',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: userData.name);
    _ageController = TextEditingController(text: userData.age.toString());
    _weightController = TextEditingController(text: userData.weight.toString());
    _heightController = TextEditingController(text: userData.height.toString());
    _selectedGoal = userData.goal;
    _dietaryPreferences = List.from(userData.dietaryPreferences);
    
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
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      userData.updateProfile(
        name: _nameController.text,
        age: int.tryParse(_ageController.text),
        weight: double.tryParse(_weightController.text),
        height: double.tryParse(_heightController.text),
        goal: _selectedGoal,
        dietaryPreferences: _dietaryPreferences,
      );
      setState(() {
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check_rounded : Icons.edit_rounded),
            onPressed: () {
              if (_isEditing) {
                _saveProfile();
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Picture Section
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 250),
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
                      child: NeomorphicContainer(
                        padding: EdgeInsets.zero,
                        width: 120,
                        height: 120,
                        borderRadius: BorderRadius.circular(60),
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: AppTheme.primaryOrange.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.person_rounded,
                                  size: 60,
                                  color: AppTheme.primaryOrange,
                                ),
                              ),
                            ),
                            if (_isEditing)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryOrange,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Personal Information
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Personal Information',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        NeomorphicContainer(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              _buildTextField(
                                label: 'Full Name',
                                controller: _nameController,
                                icon: Icons.person_outline_rounded,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                label: 'Age',
                                controller: _ageController,
                                icon: Icons.cake_rounded,
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      label: 'Weight (kg)',
                                      controller: _weightController,
                                      icon: Icons.monitor_weight_rounded,
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildTextField(
                                      label: 'Height (cm)',
                                      controller: _heightController,
                                      icon: Icons.height_rounded,
                                      keyboardType: TextInputType.number,
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

                  const SizedBox(height: 24),

                  // Fitness Goals
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fitness Goals',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        NeomorphicContainer(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Primary Goal',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 12),
                              ..._goals.map((goal) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: RadioListTile<String>(
                                      title: Text(goal),
                                      value: goal,
                                      groupValue: _selectedGoal,
                                      onChanged: _isEditing
                                          ? (value) {
                                              setState(() {
                                                _selectedGoal = value!;
                                              });
                                            }
                                          : null,
                                      activeColor: AppTheme.primaryOrange,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Dietary Preferences
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 400),
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
                          'Dietary Preferences',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        NeomorphicContainer(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Select your dietary preferences',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppTheme.gray600,
                                    ),
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _availablePreferences.map((preference) {
                                  final isSelected = _dietaryPreferences.contains(preference);
                                  return FilterChip(
                                    label: Text(preference),
                                    selected: isSelected,
                                    onSelected: _isEditing
                                        ? (selected) {
                                            setState(() {
                                              if (selected) {
                                                _dietaryPreferences.add(preference);
                                              } else {
                                                _dietaryPreferences.remove(preference);
                                              }
                                            });
                                          }
                                        : null,
                                    selectedColor: AppTheme.primaryOrange.withValues(alpha: 0.2),
                                    checkmarkColor: AppTheme.primaryOrange,
                                    labelStyle: TextStyle(
                                      color: isSelected ? AppTheme.primaryOrange : AppTheme.gray700,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Account Settings
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 400),
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
                          'Account Settings',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        NeomorphicContainer(
                          padding: EdgeInsets.zero,
                          child: Column(
                            children: [
                              _buildSettingTile(
                                icon: Icons.post_add_rounded,
                                title: 'My Posts',
                                subtitle: 'View and manage your recipes',
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('My Posts feature coming soon!'),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                              ),
                              Divider(height: 1, color: AppTheme.gray200),
                              _buildSettingTile(
                                icon: Icons.notifications_outlined,
                                title: 'Notifications',
                                subtitle: 'Manage notification preferences',
                                onTap: () {},
                              ),
                              Divider(height: 1, color: AppTheme.gray200),
                              _buildSettingTile(
                                icon: Icons.lock_outline_rounded,
                                title: 'Privacy & Security',
                                subtitle: 'Manage your privacy settings',
                                onTap: () {},
                              ),
                              Divider(height: 1, color: AppTheme.gray200),
                              _buildSettingTile(
                                icon: Icons.help_outline_rounded,
                                title: 'Help & Support',
                                subtitle: 'Get help and contact support',
                                onTap: () {},
                              ),
                              Divider(height: 1, color: AppTheme.gray200),
                              _buildSettingTile(
                                icon: Icons.info_outline_rounded,
                                title: 'About',
                                subtitle: 'App version and information',
                                onTap: () {},
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      enabled: _isEditing,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primaryOrange),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.gray300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryOrange, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryOrange),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.gray600,
            ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.gray400),
      onTap: onTap,
    );
  }
}
