import 'package:clipo_app/database/local/repo/category_repo.dart';
import 'package:clipo_app/database/local/repo/link_repo.dart';
import 'package:clipo_app/ui/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:clipo_app/database/local/db/appDatabase.dart';
import 'package:clipo_app/models/Link.dart';
import 'package:clipo_app/models/Category.dart';
import 'package:clipo_app/ui/widgets/forms/InputField.dart';
import 'package:clipo_app/ui/widgets/forms/CategoryDropdownWidget.dart';
class AddLinkScreen extends StatefulWidget {
  const AddLinkScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<AddLinkScreen> createState() => _AddLinkScreenState();
}

class _AddLinkScreenState extends State<AddLinkScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  final _newCategoryController = TextEditingController();
  late final AppDatabase _database;
  CategoryModel? _selectedCategory;
  bool _isFavorite = false;
  bool _isArchive = false;
  bool _showMetadataPreview = false;
  bool _isLoading = false;
  bool _isCategoriesLoading = false;
  bool _isCreatingNewCategory = false;
  bool _showCreateCategoryForm = false;

  List<CategoryModel> _categories = [];
  late LinkRepo _linkRepo;
  late CategoryRepo _categoryRepo;

  @override
  void initState() {
    super.initState();
    _database = AppDatabase();
    _linkRepo = LinkRepo(_database);
    _categoryRepo = CategoryRepo(_database);
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      setState(() => _isCategoriesLoading = true);
      final categories = await _categoryRepo.getAllCategories();
      setState(() {
        _categories = categories;
        _isCategoriesLoading = false;
      });
    } catch (e) {
      setState(() => _isCategoriesLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading categories: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  Future<void> _createNewCategory() async {
    if (_newCategoryController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Category name cannot be empty'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      return;
    }

    setState(() => _isCreatingNewCategory = true);

    try {
      // Create new category with default icon and color
      final newCategory = CategoryModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _newCategoryController.text.trim(),
        description: null,
        icon: 'category', // Default icon
        color: 'blue', // Default color
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to database
      await _categoryRepo.saveSingleEntity(newCategory);

      // Reload categories
      await _loadCategories();

      // Select the newly created category
      setState(() {
        _selectedCategory = newCategory;
        _showCreateCategoryForm = false;
        _newCategoryController.clear();
      });

      if (mounted) {
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
      setState(() => _isCreatingNewCategory = false);
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    _newCategoryController.dispose();
    super.dispose();
  }

  String? _validateUrl(String? value) {
    if (value?.isEmpty ?? true) {
      return 'URL is required';
    }
    
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$'
    );
    
    if (!urlRegex.hasMatch(value!)) {
      return 'Please enter a valid URL (e.g., https://example.com)';
    }
    
    return null;
  }

  String? _validateTitle(String? value) {
    if (value != null && value.isNotEmpty) {
      if (value.length < 3) {
        return 'Title must be at least 3 characters long';
      }
      if (value.length > 100) {
        return 'Title must be less than 100 characters';
      }
    }
    return null;
  }

  String? _validateDescription(String? value) {
    if (value != null && value.isNotEmpty) {
      if (value.length > 500) {
        return 'Description must be less than 500 characters';
      }
    }
    return null;
  }

  String? _validateNotes(String? value) {
    if (value != null && value.isNotEmpty) {
      if (value.length > 1000) {
        return 'Notes must be less than 1000 characters';
      }
    }
    return null;
  }

  String? _validateCategory(CategoryModel? value) {
    if (value == null && !_showCreateCategoryForm) {
      return 'Please select a category or create a new one';
    }
    return null;
  }

  String? _validateNewCategoryName(String? value) {
    if (_showCreateCategoryForm) {
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
      final existingCategory = _categories.any(
        (cat) => cat.name.toLowerCase() == value.trim().toLowerCase(),
      );
      if (existingCategory) {
        return 'A category with this name already exists';
      }
    }
    return null;
  }

  void _saveLink() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        CategoryModel? categoryToUse;

        // If creating new category, create it first
        if (_showCreateCategoryForm && _newCategoryController.text.trim().isNotEmpty) {
          final newCategory = CategoryModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: _newCategoryController.text.trim(),
            description: null,
            icon: 'category',
            color: 'blue',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          
          await _categoryRepo.saveSingleEntity(newCategory);
          categoryToUse = newCategory;
        }else {
        categoryToUse = _selectedCategory;
         }

        // Create LinkModel instance
        final linkModel = LinkModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          url: _urlController.text.trim(),
          title: _titleController.text.trim().isEmpty ? '' : _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          category: categoryToUse,
          isFavorite: _isFavorite,
          isArchived: _isArchive,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        // Save to database
        await _linkRepo.saveSingleEntity(linkModel);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Link saved successfully!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving link: ${e.toString()}'),
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
    } else {
      // Show validation errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter correct data'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add Link',
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
                    // URL Field
                    InputFieldWidget(
                      controller: _urlController,
                      label: 'URL',
                      hint: 'https://example.com',
                      validator: _validateUrl,
                      keyboardType: TextInputType.url,
                      prefixIcon: Icons.link,
                    ),
                    const SizedBox(height: 20),

                    // Title Field
                    InputFieldWidget(
                      controller: _titleController,
                      label: 'Title (optional)',
                      hint: 'Enter title',
                      validator: _validateTitle,
                      prefixIcon: Icons.title,
                    ),
                    const SizedBox(height: 20),

                    // Description Field
                    InputFieldWidget(
                      controller: _descriptionController,
                      label: 'Description (optional)',
                      hint: 'Enter description',
                      maxLines: 3,
                      validator: _validateDescription,
                      prefixIcon: Icons.description,
                    ),
                    const SizedBox(height: 20),

                    // Notes Field
                    InputFieldWidget(
                      controller: _notesController,
                      label: 'Notes (optional)',
                      hint: 'Add your notes',
                      maxLines: 3,
                      validator: _validateNotes,
                      prefixIcon: Icons.note,
                    ),
                    const SizedBox(height: 24),

                    // Category Selection/Creation
                    _buildCategorySection(),
                    const SizedBox(height: 24),

                    // Toggle Options
                    _buildToggleOption(
                      title: 'Favorite',
                      value: _isFavorite,
                      onChanged: (value) => setState(() => _isFavorite = value),
                      icon: Icons.favorite_outline,
                    ),
                    const SizedBox(height: 16),

                    _buildToggleOption(
                      title: 'Archive',
                      value: _isArchive,
                      onChanged: (value) => setState(() => _isArchive = value),
                      icon: Icons.archive_outlined,
                    ),
                    const SizedBox(height: 24),

                    // Metadata Preview
                    _buildMetadataPreview(),
                  ],
                ),
              ),
            ),

            // Bottom Actions
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }


  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Category',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _showCreateCategoryForm = !_showCreateCategoryForm;
                  if (!_showCreateCategoryForm) {
                    _newCategoryController.clear();
                  }
                  if (_showCreateCategoryForm) {
                    _selectedCategory = null;
                  }
                });
              },
              icon: Icon(
                _showCreateCategoryForm ? Icons.arrow_drop_up : Icons.add,
                size: 18,
              ),
              label: Text(
                _showCreateCategoryForm ? 'Select Existing' : 'Create New',
                style: const TextStyle(fontSize: 12),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        if (_showCreateCategoryForm) ...[
          // Create new category form
          InputFieldWidget(
            controller: _newCategoryController,
            label: 'New Category Name',
            hint: 'Enter category name',
            validator: _validateNewCategoryName,
            prefixIcon: Icons.add_circle_outline,
          ),
        ] else ...[
          // Existing category dropdown
          _buildCategoryDropdown(),
        ],
      ],
    );
  }
Widget _buildCategoryDropdown() {
  return CategoryDropdownWidget(
    categories: _categories,
    selectedCategory: _selectedCategory,
    isLoading: _isCategoriesLoading,
    validator: _validateCategory,
    onRetry: _loadCategories,
    onChanged: (value) {
      setState(() {
        _selectedCategory = value;
      });
    },
  );
}
  // Helper methods to get icon and color from stored values
  IconData _getCategoryIcon(String? iconName) {
    // You'll need to implement this based on how you store icons in your CategoryModel
    // This is a simple mapping example
    switch (iconName?.toLowerCase()) {
      case 'computer':
        return Icons.computer;
      case 'palette':
        return Icons.palette;
      case 'business':
        return Icons.business;
      case 'school':
        return Icons.school;
      case 'movie':
        return Icons.movie;
      case 'health_and_safety':
        return Icons.health_and_safety;
      case 'flight':
        return Icons.flight;
      case 'restaurant':
        return Icons.restaurant;
      case 'sports_soccer':
        return Icons.sports_soccer;
      case 'newspaper':
        return Icons.newspaper;
      default:
        return Icons.category;
    }
  }

  Color _getCategoryColor(String? colorName) {
    // You'll need to implement this based on how you store colors in your CategoryModel
    // This is a simple mapping example
    switch (colorName?.toLowerCase()) {
      case 'blue':
        return Colors.blue;
      case 'purple':
        return Colors.purple;
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      case 'red':
        return Colors.red;
      case 'teal':
        return Colors.teal;
      case 'indigo':
        return Colors.indigo;
      case 'amber':
        return Colors.amber;
      case 'deeporange':
        return Colors.deepOrange;
      case 'bluegrey':
        return Colors.blueGrey;
      default:
        return Colors.grey;
    }
  }

  Widget _buildToggleOption({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: value ? Colors.blue : Colors.grey[400],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataPreview() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ExpansionTile(
        title: const Text(
          'Metadata Preview',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        subtitle: const Text(
          'This is a preview of the metadata for this link',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.image,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _titleController.text.trim().isEmpty
                      ? 'Link Title Preview'
                      : _titleController.text.trim(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _descriptionController.text.trim().isEmpty
                      ? 'Link description will appear here once the URL is processed'
                      : _descriptionController.text.trim(),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                if (_selectedCategory != null || (_showCreateCategoryForm && _newCategoryController.text.trim().isNotEmpty))
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _selectedCategory != null 
                              ? _getCategoryColor(_selectedCategory!.color).withOpacity(0.1)
                              : Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _selectedCategory != null 
                                  ? _getCategoryIcon(_selectedCategory!.icon)
                                  : Icons.category,
                              color: _selectedCategory != null 
                                  ? _getCategoryColor(_selectedCategory!.color)
                                  : Colors.blue,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _selectedCategory?.name ?? _newCategoryController.text.trim(),
                              style: TextStyle(
                                fontSize: 12,
                                color: _selectedCategory != null 
                                    ? _getCategoryColor(_selectedCategory!.color)
                                    : Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
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
              onPressed: (_isLoading || _isCategoriesLoading || _isCreatingNewCategory) ? null : _saveLink,
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
            onPressed: _isLoading ? null : () => Navigator.pop(context),
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
    );
  }
}