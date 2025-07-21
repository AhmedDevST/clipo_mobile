import 'package:clipo_app/ui/widgets/dialog/awesome_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:clipo_app/database/local/repo/category_repo.dart';
import 'package:clipo_app/database/local/db/appDatabase.dart';
import 'package:clipo_app/models/Category.dart';
import 'package:clipo_app/ui/widgets/forms/InputField.dart';
import 'package:clipo_app/ui/screens/categories/categoires_screen.dart';
import 'package:clipo_app/utils/category_utils.dart';
import 'package:clipo_app/ui/widgets/forms/Cancel_btn.dart';
import 'package:clipo_app/ui/widgets/forms/submit_btn.dart';

class EditCategoryPage extends StatefulWidget {
  final CategoryModel category;
  final Function(CategoryModel)? onCategoryUpdated;
  final List<CategoryModel>? existingCategories;

  const EditCategoryPage({
    Key? key,
    required this.category,
    this.onCategoryUpdated,
    this.existingCategories,
  }) : super(key: key);

  @override
  State<EditCategoryPage> createState() => _EditCategoryPageState();
}

class _EditCategoryPageState extends State<EditCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  late final AppDatabase _database;
  late final CategoryRepo _categoryRepo;

  String _selectedColor = 'blue';
  String _selectedIcon = 'category';
  bool _setAsDefault = false;
  bool _isLoading = false;
  bool _hasChanges = false;

  // Available colors
  final List<Map<String, dynamic>> _colors = CategoryUtils.getAvailableColors();
  // Available icons
  final List<Map<String, dynamic>> _icons = CategoryUtils.getAvailableIcons();

  @override
  void initState() {
    super.initState();
    _database = AppDatabase();
    _categoryRepo = CategoryRepo(_database);
    _initializeFields();
  }

  void _initializeFields() {
    _nameController.text = widget.category.name;
    _descriptionController.text = widget.category.description ?? '';
    _selectedColor = widget.category.color;
    _selectedIcon = widget.category.icon ?? 'category';
    _setAsDefault = widget.category.isDefault ?? false;

    // Listen for changes
    _nameController.addListener(_onFieldChanged);
    _descriptionController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {
      _hasChanges = _checkForChanges();
    });
  }

  bool _checkForChanges() {
    return _nameController.text.trim() != widget.category.name ||
        _descriptionController.text.trim() !=
            (widget.category.description ?? '') ||
        _selectedColor != widget.category.color ||
        _selectedIcon != widget.category.icon ||
        _setAsDefault != (widget.category.isDefault ?? false);
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

    // Check if category name already exists (excluding current category)
    final existingCategories = widget.existingCategories ?? [];
    final nameExists = existingCategories.any(
      (cat) =>
          cat.id != widget.category.id &&
          cat.name.toLowerCase() == value.trim().toLowerCase(),
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

  Future<void> _updateCategory() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final updatedCategory = CategoryModel(
          id: widget.category.id,
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

        // Update in database
        await _categoryRepo.saveSingleEntity(updatedCategory);

        if (mounted) {
          // Call callback if provided
          widget.onCategoryUpdated?.call(updatedCategory);

          // Show success message
          AwesomeSnackBarUtils.showSuccess(
              context: context,
              title: "update category",
              message:
                  'Category "${updatedCategory.name}" updated successfully!');
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const CategoriesScreen()));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating category: ${e.toString()}'),
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

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final bool? shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Discard Changes?',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          content: const Text(
            'You have unsaved changes. Are you sure you want to discard them?',
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Keep Editing',
                style: TextStyle(color: Colors.blue),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text(
                'Discard',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );

    return shouldDiscard ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black87),
            onPressed: () async {
              if (await _onWillPop()) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CategoriesScreen()));
              }
            },
          ),
          title: const Text(
            'Edit Category',
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

              // Bottom Action Buttons
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
                        child: SubmitBtnWidget(
                            isLoading: _isLoading,
                            isEnabled: _isLoading,
                            onPressed: _updateCategory)),
                    const SizedBox(height: 12),
                    CancelbtnWidget(
                        isEnabled: _isLoading,
                        isLoading: _isLoading,
                        onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const CategoriesScreen()))),
                  ],
                ),
              ),
            ],
          ),
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
                  _hasChanges = _checkForChanges();
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
                  _hasChanges = _checkForChanges();
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? CategoryUtils.getColorFromName(_selectedColor)
                          .withOpacity(0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border.all(
                          color: CategoryUtils.getColorFromName(_selectedColor),
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
                      ? CategoryUtils.getColorFromName(_selectedColor)
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
                _hasChanges = _checkForChanges();
              });
            },
            activeColor: Colors.blue,
          ),
        ],
      ),
    );
  }
}
