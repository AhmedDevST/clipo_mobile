
import 'package:clipo_app/database/local/db/appDatabase.dart';
import 'package:clipo_app/database/local/repo/link_repo.dart';
import 'package:clipo_app/models/Link.dart';
import 'package:flutter/material.dart';
import 'package:clipo_app/screens/add_link_screen.dart';
import 'package:clipo_app/screens/search_screen.dart';
import 'package:url_launcher/url_launcher.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<LinkModel> _links = [];
  late final AppDatabase _database;
  late final LinkRepo _linkRepo;

  @override
  void initState() {
    super.initState();
    _database = AppDatabase();    // Instantiate your database (adjust if using DI)
    _linkRepo = LinkRepo(_database);

    _loadLinks();
  }

  Future<void> _loadLinks() async {
    final links = await _linkRepo.getAllLinks();
    setState(() {
      _links = links;
    });
  }

  Future<void> _deleteLink(String id) async {
    await _linkRepo.deleteLink(id);
    await _loadLinks(); // Refresh after deletion
  }

  void _refreshData() {
    _loadLinks();
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  void dispose() {
    _database.close(); // Close DB when widget disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestionnaire de Liens'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchScreen(categories: []), 
                ),
              ).then((_) => _refreshData());
            },
          ),
        ],
      ),
      body: _links.isEmpty
          ? Center(child: Text('Aucun lien enregistré'))
          : ListView.builder(
              itemCount: _links.length,
              itemBuilder: (context, index) {
                final link = _links[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(
                      link.url,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Catégorie: ${link.category?.name ?? "Non définie"}'),
                        Text('Date: ${_formatDate(link.createdAt)}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteLink(link.id),
                    ),
                    onTap: () {
                      try {
                        _launchURL(link.url);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erreur lors de l\'ouverture du lien: $e')),
                        );
                      }
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddLinkScreen(url: ''),
            ),
          ).then((_) => _refreshData());
        },
        child: Icon(Icons.add),
        tooltip: 'Ajouter un lien',
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
