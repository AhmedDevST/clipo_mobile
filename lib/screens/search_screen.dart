import 'package:flutter/material.dart';
import 'package:clipo_app/models/category.dart';
import 'package:clipo_app/models/link.dart';


class SearchScreen extends StatefulWidget {
  final List<CategoryModel> categories;

  SearchScreen({required this.categories});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  CategoryModel? _selectedCategory;

  DateTime? _startDate;
  DateTime? _endDate;

  List<LinkModel> _searchResults = [];
  bool _hasSearched = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rechercher des liens'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rechercher par catégorie', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            DropdownButtonFormField<CategoryModel>(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Sélectionnez une catégorie',
              ),
              value: _selectedCategory,
              items: [
                ...widget.categories.map((category) {
                  return DropdownMenuItem<CategoryModel>(
                    value: category,
                    child: Text(category.name),
                  );
                }).toList(),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
            
            SizedBox(height: 20),
            
            Text('Rechercher par date', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, true),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Date de début',
                      ),
                      child: Text(
                        _startDate == null 
                            ? 'Sélectionner' 
                            : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, false),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Date de fin',
                      ),
                      child: Text(
                        _endDate == null 
                            ? 'Sélectionner' 
                            : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 20),
            
            ElevatedButton(
              onPressed: _search,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Text('Rechercher'),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            Expanded(
              child: !_hasSearched
                  ? Center(child: Text('Veuillez effectuer une recherche'))
                  : _searchResults.isEmpty
                      ? Center(child: Text('Aucun résultat'))
                      : ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final link = _searchResults[index];
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 5),
                              child: ListTile(
                                title: Text(link.url),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Catégorie: ${link.category?.name ?? "Non définie"}'),
                                    Text('Date: ${_formatDate(link.createdAt)}'),
                                  ],
                                ),
                                onTap: () {
                                  // Ouvrir le lien (nécessite url_launcher)
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Ouverture du lien: ${link.url}')),
                                  );
                                },
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _search() {
    setState(() {
      _hasSearched = true;
      
    });
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}