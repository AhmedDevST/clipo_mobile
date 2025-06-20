import 'package:clipo_app/database/local/db/appDatabase.dart';
import 'package:clipo_app/database/local/repo/category_repo.dart';
import 'package:clipo_app/models/Category.dart';
import 'package:flutter/material.dart';
import 'package:clipo_app/ui/widgets/category_card.dart';
import 'package:clipo_app/ui/widgets/bottom_navigation_bar.dart';
import 'package:clipo_app/ui/widgets/loading_widget.dart';
import 'package:clipo_app/ui/widgets/empty_state_widget.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final int _selectedIndex = 1;

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
            onPressed: () {},
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
                      onAction: () {},
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
                        return CategoryCard(category: _categories[index]);
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
