import 'package:clipo_app/models/Link.dart';
import 'package:flutter/material.dart';
import 'package:clipo_app/database/local/db/appDatabase.dart';
import 'package:clipo_app/database/local/repo/link_repo.dart';
import 'package:clipo_app/ui/widgets/bottom_navigation_bar.dart';
import 'package:clipo_app/ui/widgets/empty_state_widget.dart';
import 'package:clipo_app/ui/widgets/links_list_widget.dart';
import 'package:clipo_app/ui/widgets/loading_widget.dart';
import 'package:clipo_app/mixins/link_actions_mixin.dart';
import 'package:clipo_app/ui/widgets/dialog/awesome_snackbar.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with TickerProviderStateMixin, LinkActionsMixin {
  final int _selectedIndex = 3;

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
  Future<void> reloadLinks() => _loadLinks(refresh: true);

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

  Future<void> _loadLinks({bool refresh = false}) async {
    if (refresh) {
      resetPagination();
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final initialLinks = await _linkRepo.getFavoriteLinksPaginated(
        limit: pageSize,
        offset: 0,
      );

      setState(() {
        _links = initialLinks;
        updatePaginationState(initialLinks);
        _isLoading = false;
      });

      _animationController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreFavorites() async {
    await loadMore(
      loadFunction: (limit, offset) => _linkRepo.getFavoriteLinksPaginated(
        limit: limit,
        offset: offset,
      ),
    );
  }

  // Override toggleFavorite to reload links after toggling
  @override
  Future<void> toggleFavorite(LinkModel link) async {
    try {
      await linkRepo.toggleIsFavorite(link.id!);
      final updatedLink = link.copyWith(isFavorite: !link.isFavorite);

      setState(() {
        final index = links.indexWhere((l) => l.id == link.id);
        if (index != -1) {
          links[index] = updatedLink;
        }
      });

      await reloadLinks(); // Reload to update favorites list
      AwesomeSnackBarUtils.showSuccess(
          context: context,
          title: 'Favorites',
          message: updatedLink.isFavorite
              ? 'Added to favorites'
              : 'Removed from favorites');
    } catch (e) {
      AwesomeSnackBarUtils.showError(
          context: context,
          title: 'Error',
          message: 'Error updating favorite: $e');
    }
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
        'Favorites',
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: () async => _loadLinks(refresh: true),
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
                  title: 'No favorite links saved yet',
                )
              : LinksListWidget(
                  links: _links,
                  onEdit: (link) => handleEditLink(link),
                  onTap: (link) => handleLinkTap(link),
                  onDelete: (link) => deleteLink(link),
                  onToggleFavorite: (link) => toggleFavorite(link),
                  onShare: (link) => shareLink(link),
                  fadeAnimation: _fadeAnimation,
                  hasMoreData: hasMoreData,
                  isLoadingMore: isLoadingMore,
                  onLoadMore: _loadMoreFavorites,
                ),
    );
  }
}