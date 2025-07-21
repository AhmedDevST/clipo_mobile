import 'package:clipo_app/models/Link.dart';
import 'package:clipo_app/ui/screens/links/serach_screen.dart';
import 'package:clipo_app/ui/widgets/empty_state_widget.dart';
import 'package:clipo_app/ui/widgets/links_list_widget.dart';
import 'package:clipo_app/ui/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:clipo_app/database/local/db/appDatabase.dart';
import 'package:clipo_app/database/local/repo/link_repo.dart';
import 'package:clipo_app/ui/widgets/bottom_navigation_bar.dart';
import 'package:clipo_app/ui/screens/links/add_link_screen.dart';
import 'package:clipo_app/mixins/link_actions_mixin.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, LinkActionsMixin {
  final int _selectedIndex = 0;

  late List<LinkModel> _links = [];
  late final AppDatabase _database;
  late final LinkRepo _linkRepo;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = true;

  // Getters required by the mixin
  @override
  LinkRepo get linkRepo => _linkRepo;

  @override
  List<LinkModel> get links => _links;

  @override
  set links(List<LinkModel> value) => _links = value;

  @override
  Future<void> reloadLinks() => _loadLinks();

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
    _initializeAnimations();
    _loadLinks();
  }

  void _initializeDatabase() {
    _database = AppDatabase();
    _linkRepo = LinkRepo(_database);
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _loadLinks() async {
    setState(() {
      _isLoading = true;
    });

    final links = await _linkRepo.getAllLinks();
    setState(() {
      _links = links;
      _isLoading = false;
    });

    _animationController.forward();
  }

  // Navigation methods
  void _navigateToSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SearchScreen()),
    );
  }

  void _navigateToAddLink() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddLinkScreen()),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _database.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBarWidget(
        selectedIndex: _selectedIndex,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'LinkSaver',
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(Icons.search_outlined, color: Colors.black87),
          onPressed: _navigateToSearch,
        ),
      ),
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: () async => _loadLinks(),
      color: Colors.blue[600],
      child: _isLoading
          ? LoadingWidget(
              message: 'Loading data...',
              textColor: Colors.blue,
              fontSize: 18,
            )
          : _links.isEmpty
              ? EmptyStateWidget(
                  icon: Icons.link_off_outlined,
                  title: 'No links saved yet',
                  subtitle: 'Save your first link to get started.',
                  actionText: 'Add Link',
                  onAction: () {
                    _navigateToAddLink();
                  },
                )
              : LinksListWidget(
                  links: _links,
                  onEdit: (link) => handleEditLink(link),
                  onTap: (link) => handleLinkTap(link),
                  onDelete: (link) => deleteLink(link),
                  onToggleFavorite: (link) => toggleFavorite(link),
                  onShare: (link) => shareLink(link),
                  fadeAnimation: _fadeAnimation,
                ),
    );
  }
}
