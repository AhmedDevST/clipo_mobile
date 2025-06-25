import 'package:flutter/material.dart';
import 'package:clipo_app/database/local/repo/category_repo.dart';
import 'package:clipo_app/database/local/db/appDatabase.dart';
import 'package:clipo_app/models/Category.dart';
import 'package:clipo_app/ui/widgets/forms/InputField.dart';

class NewCategoryPage extends StatefulWidget {
  final Function(CategoryModel)? onCategoryCreated;
  final List<CategoryModel>? existingCategories;

  const NewCategoryPage({
    Key? key,
    this.onCategoryCreated,
    this.existingCategories,
  }) : super(key: key);

  @override
  State<NewCategoryPage> createState() => _NewCategoryPageState();
}

class _NewCategoryPageState extends State<NewCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  late final AppDatabase _database;
  late final CategoryRepo _categoryRepo;
  
  String _selectedColor = 'blue';
  String _selectedIcon = 'category';
  bool _setAsDefault = false;
  bool _isLoading = false;

  // Available colors
  final List<Map<String, dynamic>> _colors = [
    {'name': 'red', 'color': Colors.red},
    {'name': 'green', 'color': Colors.green},
    {'name': 'blue', 'color': Colors.blue},
    {'name': 'purple', 'color': Colors.purple},
    {'name': 'orange', 'color': Colors.orange},
    {'name': 'teal', 'color': Colors.teal},
    {'name': 'indigo', 'color': Colors.indigo},
    {'name': 'pink', 'color': Colors.pink},
  ];

  // Available icons
  final List<Map<String, dynamic>> _icons = [
    {'name': 'bookmark', 'icon': Icons.bookmark_outline},
    {'name': 'folder', 'icon': Icons.folder_outlined},
    {'name': 'file', 'icon': Icons.insert_drive_file_outlined},
    {'name': 'link', 'icon': Icons.link},
    {'name': 'globe', 'icon': Icons.public},
    {'name': 'star', 'icon': Icons.star_outline},
    {'name': 'category', 'icon': Icons.category_outlined},
    {'name': 'work', 'icon': Icons.work_outline},
    {'name': 'school', 'icon': Icons.school_outlined},
    {'name': 'home', 'icon': Icons.home_outlined},
    {'name': 'shopping', 'icon': Icons.shopping_cart_outlined},
    {'name': 'sports', 'icon': Icons.sports_soccer_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _database = AppDatabase();
    _categoryRepo = CategoryRepo(_database);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value?.trim().isEmpty ?? true) {
      return 'Category name is required';
    }
    
    if (value!.trim().length < 2) {
      return 'Category name must be at least 2 characters';
    }
    
    if (value.trim().length > 50) {
      return 'Category name must be less than 50 characters';
    }
    
    // Check if category name already exists
    final existingCategories = widget.existingCategories ?? [];
    final nameExists = existingCategories.any(
      (cat) => cat.name.toLowerCase() == value.trim().toLowerCase(),
    );
    
    if (nameExists) {
      return 'A category with this name already exists';
    }
    
    return null;
  }

  String? _validateDescription(String? value) {
    if (value != null && value.isNotEmpty) {
      if (value.length > 200) {
        return 'Description must be less than 200 characters';
      }
    }
    return null;
  }

  Color _getColorFromName(String colorName) {
    final colorMap = _colors.firstWhere(
      (c) => c['name'] == colorName,
      orElse: () => {'name': 'blue', 'color': Colors.blue},
    );
    return colorMap['color'] as Color;
  }

  IconData _getIconFromName(String iconName) {
    final iconMap = _icons.firstWhere(
      (i) => i['name'] == iconName,
      orElse: () => {'name': 'category', 'icon': Icons.category_outlined},
    );
    return iconMap['icon'] as IconData;
  }

  Future<void> _saveCategory() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        final newCategory = CategoryModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty 
              ? null 
              : _descriptionController.text.trim(),
          color: _selectedColor,
          icon: _selectedIcon,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isDefault: _setAsDefault,
        );

        // Save to database
        await _categoryRepo.saveSingleEntity(newCategory);

        if (mounted) {
          // Call callback if provided
          widget.onCategoryCreated?.call(newCategory);
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Category "${newCategory.name}" created successfully!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
          
          // Navigate back with result
          Navigator.of(context).pop(newCategory);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error creating category: ${e.toString()}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'New Category',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name Field
                    InputFieldWidget(
                      controller: _nameController,
                      label: 'Name',
                      hint: 'Name',
                      validator: _validateName,
                      prefixIcon: Icons.label_outline,
                    ),
                    const SizedBox(height: 20),

                    // Description Field
                    InputFieldWidget(
                      controller: _descriptionController,
                      label: 'Description',
                      hint: 'Description',
                      maxLines: 3,
                      validator: _validateDescription,
                      prefixIcon: Icons.description_outlined,
                    ),
                    const SizedBox(height: 24),

                    // Color Selection
                    _buildColorSection(),
                    const SizedBox(height: 24),

                    // Icon Selection
                    _buildIconSection(),
                    const SizedBox(height: 24),

                    // Set as Default
                    _buildDefaultToggle(),
                  ],
                ),
              ),
            ),

            // Bottom Save Button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveCategory,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: Colors.grey[300],
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Save',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Color',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _colors.map((colorData) {
            final colorName = colorData['name'] as String;
            final color = colorData['color'] as Color;
            final isSelected = _selectedColor == colorName;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColor = colorName;
                });
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: Colors.white, width: 3)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                    if (isSelected)
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 20,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildIconSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Icon',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: _icons.length,
          itemBuilder: (context, index) {
            final iconData = _icons[index];
            final iconName = iconData['name'] as String;
            final icon = iconData['icon'] as IconData;
            final isSelected = _selectedIcon == iconName;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIcon = iconName;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected 
                      ? _getColorFromName(_selectedColor).withOpacity(0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border.all(
                          color: _getColorFromName(_selectedColor),
                          width: 2,
                        )
                      : Border.all(color: Colors.grey[300]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: isSelected 
                      ? _getColorFromName(_selectedColor)
                      : Colors.grey[600],
                  size: 24,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDefaultToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.star_outline,
            color: _setAsDefault ? Colors.amber : Colors.grey[400],
            size: 20,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Set as default',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Switch.adaptive(
            value: _setAsDefault,
            onChanged: (value) {
              setState(() {
                _setAsDefault = value;
              });
            },
            activeColor: Colors.blue,
          ),
        ],
      ),
    );
  }
}