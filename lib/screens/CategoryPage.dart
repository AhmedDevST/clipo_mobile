import 'package:clipo_app/database/local/db/appDatabase.dart';
import 'package:clipo_app/database/local/repo/category_repo.dart';
import 'package:clipo_app/models/Category.dart';
import 'package:flutter/material.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late final CategoryRepo _categoryRepo;
  List<CategoryModel> _categories = [];

  @override
  void initState() {
    super.initState();
    final db = AppDatabase(); // Your Drift database
    _categoryRepo = CategoryRepo(db);
    loadCategories();
  }

  Future<void> loadCategories() async {
    final cats = await _categoryRepo.getAllCategories();
    setState(() {
      _categories = cats;
    });
  }

  Future<void> addCategory(CategoryModel category) async {
    await _categoryRepo.saveSingleEntity(category);
    await loadCategories();
  }

  Future<void> deleteCategory(String id) async {
    await _categoryRepo.deleteCategory(id);
    await loadCategories();
  }

  void _showAddCategoryDialog() {
    final _nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Category"),
        content: TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: "Category Name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final name = _nameController.text.trim();
              if (name.isNotEmpty) {
                final category = CategoryModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: name,
                  description: null,
                  color: '#000000', // You can customize this
                  icon: null,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                  linkCount: 0,
                  isDefault: false,
                );
                addCategory(category);
                Navigator.of(context).pop();
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Categories"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadCategories,
          ),
        ],
      ),
      body: _categories.isEmpty
          ? const Center(child: Text("No categories yet."))
          : ListView.builder(
              itemCount: _categories.length,
              itemBuilder: (_, index) {
                final category = _categories[index];
                return ListTile(
                  title: Text(category.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      deleteCategory(category.id);
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCategoryDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
