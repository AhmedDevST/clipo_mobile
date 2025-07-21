import 'package:clipo_app/database/local/repo/category_repo.dart';
import 'package:clipo_app/database/local/repo/link_repo.dart';
import 'package:clipo_app/ui/screens/home_screen.dart';
import 'package:clipo_app/ui/widgets/dialog/awesome_snackbar.dart';
import 'package:clipo_app/ui/widgets/forms/Toggle_option.dart';
import 'package:clipo_app/ui/widgets/forms/submit_btn.dart';
import 'package:flutter/material.dart';
import 'package:clipo_app/database/local/db/appDatabase.dart';
import 'package:clipo_app/models/Link.dart';
import 'package:clipo_app/models/Category.dart';
import 'package:clipo_app/ui/widgets/forms/InputField.dart';
import 'package:clipo_app/ui/widgets/forms/CategoryDropdownWidget.dart';

class EditLinkScreen extends StatefulWidget {
  final LinkModel link;
  EditLinkScreen({
    Key? key,
    required this.link,
  }) : super(key: key);

  @override
  State<EditLinkScreen> createState() => _EditLinkScreenState();
}

class _EditLinkScreenState extends State<EditLinkScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  final _newCategoryController = TextEditingController();
  late final AppDatabase _database;
  CategoryModel? _selectedCategory;
  CategoryModel? _originalCategory; // Store original category for comparison
  bool _isFavorite = false;
  bool _isArchive = false;
  bool _isLoading = false;
  bool _isCategoriesLoading = false;
  bool _isCreatingNewCategory = false;
  bool _showCreateCategoryForm = false;
  bool _hasChanges = false;
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
    _initializeFields();
  }

  void _initializeFields() {
    _urlController.text = widget.link.url;
    _titleController.text = widget.link.title;
    _descriptionController.text = widget.link.description ?? '';
    _notesController.text = widget.link.notes ?? '';
    _selectedCategory = widget.link.category;
    _originalCategory = widget.link.category; // Store original category
    _isFavorite = widget.link.isFavorite;
    _isArchive = widget.link.isArchived;

    // Listen for changes
    _urlController.addListener(_onFieldChanged);
    _descriptionController.addListener(_onFieldChanged);
    _notesController.addListener(_onFieldChanged);
    _titleController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {
      _hasChanges = _checkForChanges();
    });
  }

  bool _checkForChanges() {
    return _urlController.text.trim() != widget.link.url ||
        _titleController.text.trim() != (widget.link.title) ||
        _descriptionController.text.trim() != (widget.link.description ?? '') ||
        _notesController.text.trim() != (widget.link.notes ?? '') ||
        _isFavorite != widget.link.isFavorite ||
        _isArchive != widget.link.isArchived ||
        _selectedCategory?.id != _originalCategory?.id || // Compare category IDs
        _showCreateCategoryForm && _newCategoryController.text.trim().isNotEmpty;
  }

  Future<void> _loadCategories() async {
    try {
      setState(() => _isCategoriesLoading = true);
      final categories = await _categoryRepo.getAllCategories();
      setState(() {
        _categories = categories;
        _isCategoriesLoading = false;
        
        // If we have a selected category, find it in the loaded categories
        // to ensure we have the complete category object
        if (_selectedCategory != null) {
          final foundCategory = categories.firstWhere(
            (cat) => cat.id == _selectedCategory!.id,
            orElse: () => _selectedCategory!,
          );
          _selectedCategory = foundCategory;
        }
      });
    } catch (e) {
      setState(() => _isCategoriesLoading = false);
      if (mounted) {
        AwesomeSnackBarUtils.showError(
            context: context,
            title: "Loading Categories",
            message: 'Error loading categories');
      }
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
        r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$');

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
        if (_showCreateCategoryForm &&
            _newCategoryController.text.trim().isNotEmpty) {
          setState(() => _isCreatingNewCategory = true);
          
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
          
          // Add to categories list for future reference
          setState(() {
            _categories.add(newCategory);
            _isCreatingNewCategory = false;
          });
        } else {
          categoryToUse = _selectedCategory;
        }

        // Create updated LinkModel instance
        final linkModel = LinkModel(
          id: widget.link.id,
          url: _urlController.text.trim(),
          title: _titleController.text.trim().isEmpty
              ? ''
              : _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          category: categoryToUse,
          isFavorite: _isFavorite,
          isArchived: _isArchive,
          createdAt: widget.link.createdAt, // Keep original creation date
          updatedAt: DateTime.now(), // Update the modification date
        );

        // Save to database
        await _linkRepo.saveSingleEntity(linkModel);

        if (mounted) {
          AwesomeSnackBarUtils.showSuccess(
              context: context,
              title: "Update Link",
              message: 'Link updated successfully!');
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const HomeScreen()));
        }
      } catch (e) {
        if (mounted) {
          AwesomeSnackBarUtils.showError(
              context: context,
              title: "Update Link",
              message: 'Error updating link: ${e.toString()}');
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _isCreatingNewCategory = false;
          });
        }
      }
    } else {
      // Show validation errors
      AwesomeSnackBarUtils.showWarning(
          context: context,
          title: "Update Link",
          message: 'Please enter correct data');
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
                          builder: (context) => const HomeScreen()));
                }
              },
            ),
            title: const Text(
              'Edit Link',
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
                        ToggleOptionWidget(
                          title: 'Favorite',
                          value: _isFavorite,
                          onChanged: (value) {
                            setState(() {
                              _isFavorite = value;
                              _hasChanges = _checkForChanges();
                            });
                          },
                          icon: Icons.favorite_outline,
                        ),

                        const SizedBox(height: 16),
                        ToggleOptionWidget(
                          title: 'Archive',
                          value: _isArchive,
                          onChanged: (value) {
                            setState(() {
                              _isArchive = value;
                              _hasChanges = _checkForChanges();
                            });
                          },
                          icon: Icons.archive_outlined,
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Actions
                _buildBottomActions(),
              ],
            ),
          ),
        ));
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
                  _hasChanges = _checkForChanges();
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
          CategoryDropdownWidget(
            categories: _categories,
            selectedCategory: _selectedCategory,
            isLoading: _isCategoriesLoading,
            validator: _validateCategory,
            onRetry: _loadCategories,
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
                _hasChanges = _checkForChanges();
              });
            },
          ),
        ],
      ],
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
            child: SubmitBtnWidget(
              isEnabled: (_isLoading || _isCategoriesLoading || _isCreatingNewCategory),
              isLoading: _isLoading || _isCreatingNewCategory,
              onPressed: () => _saveLink(),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: (_isLoading || _isCreatingNewCategory)
                ? null
                : () async {
                    if (await _onWillPop()) {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomeScreen()));
                    }
                  },
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