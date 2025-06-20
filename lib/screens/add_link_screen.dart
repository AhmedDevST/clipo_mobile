import 'package:clipo_app/database/local/repo/category_repo.dart';
import 'package:clipo_app/database/local/repo/link_repo.dart';
import 'package:clipo_app/models/Category.dart';
import 'package:clipo_app/models/Link.dart';
import 'package:clipo_app/ui/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:clipo_app/database/local/db/appDatabase.dart';

class AddLinkScreen extends StatefulWidget {
  final String url;
  AddLinkScreen({required this.url});

  @override
  _AddLinkScreenState createState() => _AddLinkScreenState();
}

class _AddLinkScreenState extends State<AddLinkScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _newCategoryController = TextEditingController();
  List<CategoryModel> _categories = [];
  CategoryModel? _selectedCategory;
  bool _addingNewCategory = false;
  late final AppDatabase _database;
  late final CategoryRepo _categoryRepo;
  late final LinkRepo _linkRepo;

  @override
  void initState() {
    super.initState();
    _urlController.text = widget.url;
    _database = AppDatabase();
    _categoryRepo = CategoryRepo(_database);
    _linkRepo = LinkRepo(_database);
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await _categoryRepo.getAllCategories();
    setState(() {
      _categories = categories;
      if (_categories.isNotEmpty) {
        _selectedCategory = _categories.first;
      }
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    _newCategoryController.dispose();
    _database.close();
    super.dispose();
  }

  Future<void> _saveLink() async {
    if (_formKey.currentState!.validate()) {
      CategoryModel? categoryToUse;
      if (_addingNewCategory) {
        // Create new category
        final newCategoryName = _newCategoryController.text.trim();
        final newCategory = CategoryModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: newCategoryName,
          description: null,
          color: '#2196F3', // Default blue, adjust as needed
          icon: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          linkCount: 0,
          isDefault: false,
        );

        await _categoryRepo.saveSingleEntity(newCategory);
        categoryToUse = newCategory;
      } else {
        categoryToUse = _selectedCategory;
      }

      if (categoryToUse == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Veuillez sélectionner ou ajouter une catégorie')),
        );
        return;
      }

      final newLink = LinkModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        url: _urlController.text.trim(),
        title: '', // You can add a field and UI for title if you want
        description: null,
        favicon: null,
        thumbnail: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        lastVisited: null,
        visitCount: 0,
        isFavorite: false,
        isArchived: false,
        category: categoryToUse,
        notes: null,
        metadata: null,
      );

      await _linkRepo.saveSingleEntity(newLink);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter un lien'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'URL',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
              keyboardType: TextInputType.url,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer une URL';
                }
                if (!value.startsWith('http')) {
                  return 'L\'URL doit commencer par http:// ou https://';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            Text('Catégorie', style: TextStyle(fontSize: 16)),
            if (!_addingNewCategory) ...[
              DropdownButtonFormField<CategoryModel>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
                value: _selectedCategory,
                items: _categories.map((category) {
                  return DropdownMenuItem<CategoryModel>(
                    value: category,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Veuillez sélectionner une catégorie';
                  }
                  return null;
                },
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _addingNewCategory = true;
                  });
                },
                child: Text('Ajouter une nouvelle catégorie'),
              ),
            ] else ...[
              TextFormField(
                controller: _newCategoryController,
                decoration: InputDecoration(
                  labelText: 'Nouvelle catégorie',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom de catégorie';
                  }
                  return null;
                },
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _addingNewCategory = false;
                  });
                },
                child: Text('Utiliser une catégorie existante'),
              ),
            ],
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveLink,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Text('Enregistrer'),
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
