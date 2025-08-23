import 'package:clipo_app/database/local/db/appDatabase.dart';
import 'package:clipo_app/database/local/repo/category_repo.dart';
import 'package:clipo_app/models/Category.dart';
import 'package:flutter/material.dart';
import 'package:clipo_app/ui/widgets/category_card.dart';
import 'package:clipo_app/ui/widgets/bottom_navigation_bar.dart';
import 'package:clipo_app/ui/widgets/loading_widget.dart';
import 'package:clipo_app/ui/widgets/empty_state_widget.dart';
import 'package:clipo_app/ui/screens/categories/add_category_screen.dart';
import 'package:clipo_app/ui/screens/categories/edit_category_screen.dart';
import 'package:clipo_app/ui/widgets/dialog/ConfirmationDialog.dart';
import 'package:clipo_app/ui/widgets/dialog/awesome_snackbar.dart';
import 'package:clipo_app/ui/screens/categories/add_category_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final int _selectedIndex = 2;

  late List<CategoryModel> _categories = [];
  late final AppDatabase _database;
  late final CategoryRepo _CatRepo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
    _loadCategories();
  }

  void _initializeDatabase() {
    _database = AppDatabase();
    _CatRepo = CategoryRepo(_database);
  }

  // Data loading methods
  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
    });

    final categories = await _CatRepo.getAllCategories();
    setState(() {
      _categories = categories;
      _isLoading = false;
    });
  }
  void _navigateToAddCategory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NewCategoryPage()),
    );
  }
  Future<void> deleteCategory(CategoryModel category) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => const ConfirmationDialog(
        title: 'confirmation',
        description: "Are you sure you want to delete ",
        lottieUrl:
            "https://lottie.host/728db5d2-c7eb-4150-bb0e-cc0cc1d1ad3e/0UrRRIVVSc.json",
        confirmText: 'Delete',
        cancelText: 'Cancel',
        color: Colors.red,
      ),
    );

    if (confirmed == true) {
      try {
        await _CatRepo.deleteCategory(category.id!);
        await _loadCategories();
        AwesomeSnackBarUtils.showSuccess(
          context: context,
          title: 'Success!',
          message: 'Your operation completed successfully!',
        );
      } catch (e) {
        AwesomeSnackBarUtils.showError(
            context: context,
            title: 'Error!',
            message: 'Error deleting category: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Categories',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black87),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const NewCategoryPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: RefreshIndicator(
          onRefresh: _loadCategories,
          child: _isLoading
              ? LoadingWidget(
                  message: 'Loading data...',
                  textColor: Colors.blue,
                  fontSize: 18,
                )
              : _categories.isEmpty
                  ? EmptyStateWidget(
                      icon: Icons.link_off_outlined,
                      title: 'No categories saved yet',
                      subtitle: 'Save your first category to get started.',
                      actionText: 'Add Category',
                      onAction: () {
                          _navigateToAddCategory();
                      },
                    )
                  : GridView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.2,
                      ),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        return CategoryCard(
                            category: _categories[index],
                            onEdit: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditCategoryPage(
                                      category: _categories[index]),
                                )),
                            onDelete: () {
                              deleteCategory(_categories[index]);
                            });
                      },
                    ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        selectedIndex: _selectedIndex,
      ),
    );
  }
}
