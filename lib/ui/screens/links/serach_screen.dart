import 'package:flutter/material.dart';
import 'package:clipo_app/models/Category.dart';
import 'package:clipo_app/models/Link.dart';
import 'package:clipo_app/ui/widgets/forms/CategoryDropdownWidget.dart';
import 'package:clipo_app/ui/widgets/links_list_widget.dart';
import 'package:clipo_app/ui/widgets/empty_state_widget.dart';
import 'package:clipo_app/database/local/repo/category_repo.dart';
import 'package:clipo_app/database/local/repo/link_repo.dart';
import 'package:clipo_app/database/local/db/appDatabase.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();

  // Search and filter states
  CategoryModel? _selectedCategory;
  DateTimeRange? _selectedDateRange;
  String _selectedSort = 'Date Added (New to Old)';
  bool _showFilters = false;
  bool _favoritesOnly = false;
  bool _archivedOnly = false;
  
  late final AppDatabase _database;
  late final LinkRepo _linkRepo;
  late CategoryRepo _categoryRepo;
  
  List<CategoryModel> _categories = [];
  List<LinkModel> _searchResults = [];
  List<LinkModel> _filteredResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  bool _isCategoriesLoading = false;
  
  // Animation controllers
  late AnimationController _filterAnimationController;
  late AnimationController _fadeAnimationController;
  late Animation<double> _filterSlideAnimation;
  late Animation<double> _fadeAnimation;

  final List<String> _sortOptions = [
    'Date Added (New to Old)',
    'Date Added (Old to New)',
    'Most Visited',
    'Least Visited',
    'A-Z',
    'Z-A',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeDatabase();
    _loadCategories();
  }

  void _initializeDatabase() {
    _database = AppDatabase();
    _linkRepo = LinkRepo(_database);
    _categoryRepo = CategoryRepo(_database);
  }

  void _initializeAnimations() {
    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _filterSlideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _filterAnimationController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeInOut,
    ));
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

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
    });

    if (_showFilters) {
      _filterAnimationController.forward();
    } else {
      _filterAnimationController.reverse();
    }
  }

  Future<void> _performSearch() async {
    final queryText = _searchController.text.trim();

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      List<LinkModel> links;
      
      if (queryText.isEmpty) {
        // If no search text, get all links
        links = await _linkRepo.getAllLinks();
      } else {
        // Search with text
        links = await _linkRepo.searchLinksAdvanced(
          queryText: queryText,
          categoryId: _selectedCategory?.id,
          dateRange: _selectedDateRange,
          favoritesOnly: _favoritesOnly,
          archivedOnly: _archivedOnly,
        );
      }

      // Apply additional filters if no query text
      if (queryText.isEmpty) {
        links = _applyFilters(links);
      }

      // Apply sorting
      links = _applySorting(links);

      setState(() {
        _isLoading = false;
        _searchResults = links;
        _filteredResults = links;
      });
      _fadeAnimationController.forward();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error while searching: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  List<LinkModel> _applyFilters(List<LinkModel> links) {
    List<LinkModel> filtered = List.from(links);

    // Filter by category
    if (_selectedCategory != null) {
      filtered = filtered.where((link) => 
        link.category?.id == _selectedCategory!.id).toList();
    }

    // Filter by date range
    if (_selectedDateRange != null) {
      filtered = filtered.where((link) {
        final linkDate = link.createdAt;
        return linkDate.isAfter(_selectedDateRange!.start.subtract(const Duration(days: 1))) &&
               linkDate.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    // Filter by favorites
    if (_favoritesOnly) {
      filtered = filtered.where((link) => link.isFavorite).toList();
    }

    // Filter by archived
    if (_archivedOnly) {
      filtered = filtered.where((link) => link.isArchived).toList();
    }

    return filtered;
  }

  List<LinkModel> _applySorting(List<LinkModel> links) {
    List<LinkModel> sorted = List.from(links);

    switch (_selectedSort) {
      case 'Date Added (New to Old)':
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'Date Added (Old to New)':
        sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'Most Visited':
        sorted.sort((a, b) => b.visitCount.compareTo(a.visitCount));
        break;
      case 'Least Visited':
        sorted.sort((a, b) => a.visitCount.compareTo(b.visitCount));
        break;
      case 'A-Z':
        sorted.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case 'Z-A':
        sorted.sort((a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
        break;
    }

    return sorted;
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _selectedCategory = null;
      _selectedDateRange = null;
      _selectedSort = 'Date Added (New to Old)';
      _favoritesOnly = false;
      _archivedOnly = false;
      _searchResults = [];
      _filteredResults = [];
      _hasSearched = false;
    });
    _fadeAnimationController.reset();
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _selectedDateRange = null;
      _selectedSort = 'Date Added (New to Old)';
      _favoritesOnly = false;
      _archivedOnly = false;
    });
    if (_hasSearched) {
      _performSearch();
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue[600]!,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  bool get _hasActiveFilters {
    return _selectedCategory != null ||
           _selectedDateRange != null ||
           _favoritesOnly ||
           _archivedOnly ||
           _selectedSort != 'Date Added (New to Old)';
  }

  @override
  void dispose() {
    _filterAnimationController.dispose();
    _fadeAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchSection(),
          if (_showFilters) _buildFilterSection(),
          if (_hasActiveFilters) _buildActiveFiltersChips(),
          Expanded(
            child: _buildResultsSection(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Search Links',
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        if (_hasSearched)
          TextButton(
            onPressed: _clearSearch,
            child: Text(
              'Clear All',
              style: TextStyle(
                color: Colors.blue[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
      ),
      child: Column(
        children: [
          // Search input
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search links by title, URL, or description...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            onChanged: (value) => setState(() {}),
            onSubmitted: (value) => _performSearch(),
          ),
          const SizedBox(height: 12),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _performSearch,
                  icon: const Icon(Icons.search, size: 20),
                  label: const Text('Search'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _toggleFilters,
                icon: Icon(
                  _showFilters ? Icons.filter_list_off : Icons.filter_list,
                  size: 20,
                ),
                label: Text(_hasActiveFilters && !_showFilters ? 'Filters (${_getActiveFiltersCount()})' : 'Filters'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _showFilters || _hasActiveFilters ? Colors.blue[600] : Colors.grey[200],
                  foregroundColor: _showFilters || _hasActiveFilters ? Colors.white : Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return AnimatedBuilder(
      animation: _filterSlideAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            border: const Border(
              bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter Options',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  TextButton(
                    onPressed: _clearFilters,
                    child: Text(
                      'Clear Filters',
                      style: TextStyle(
                        color: Colors.blue[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Quick filters row
              Row(
                children: [
                  Expanded(
                    child: _buildQuickFilterChip(
                      label: 'Favorites Only',
                      isSelected: _favoritesOnly,
                      icon: Icons.favorite,
                      onTap: () {
                        setState(() {
                          _favoritesOnly = !_favoritesOnly;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildQuickFilterChip(
                      label: 'Archived Only',
                      isSelected: _archivedOnly,
                      icon: Icons.archive,
                      onTap: () {
                        setState(() {
                          _archivedOnly = !_archivedOnly;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Category filter
              _buildFilterSection2('Category', 
                CategoryDropdownWidget(
                  categories: _categories,
                  selectedCategory: _selectedCategory,
                  onChanged: (category) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Date range filter
              _buildFilterSection2('Date Range', 
                _buildDateRangeSelector(),
              ),
              const SizedBox(height: 16),

              // Sort options
              _buildFilterSection2('Sort By', 
                _buildSortDropdown(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickFilterChip({
    required String label,
    required bool isSelected,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[600] : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue[600]! : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection2(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildDateRangeSelector() {
    return GestureDetector(
      onTap: _selectDateRange,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(Icons.date_range, color: Colors.grey[400], size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedDateRange == null
                    ? 'Select date range'
                    : '${_formatDate(_selectedDateRange!.start)} - ${_formatDate(_selectedDateRange!.end)}',
                style: TextStyle(
                  color: _selectedDateRange == null
                      ? Colors.grey[400]
                      : Colors.black87,
                  fontSize: 16,
                ),
              ),
            ),
            if (_selectedDateRange != null)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDateRange = null;
                  });
                },
                child: Icon(Icons.clear, color: Colors.grey[400], size: 20),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedSort,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        isExpanded: true,
        items: _sortOptions.map((option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Row(
              children: [
                Icon(
                  _getSortIcon(option),
                  color: Colors.grey[600],
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(option),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedSort = value!;
          });
        },
      ),
    );
  }

  Widget _buildActiveFiltersChips() {
    List<Widget> chips = [];

    if (_selectedCategory != null) {
      chips.add(_buildFilterChip(
        label: 'Category: ${_selectedCategory!.name}',
        onRemove: () => setState(() => _selectedCategory = null),
      ));
    }

    if (_selectedDateRange != null) {
      chips.add(_buildFilterChip(
        label: 'Date: ${_formatDate(_selectedDateRange!.start)} - ${_formatDate(_selectedDateRange!.end)}',
        onRemove: () => setState(() => _selectedDateRange = null),
      ));
    }

    if (_favoritesOnly) {
      chips.add(_buildFilterChip(
        label: 'Favorites Only',
        onRemove: () => setState(() => _favoritesOnly = false),
      ));
    }

    if (_archivedOnly) {
      chips.add(_buildFilterChip(
        label: 'Archived Only',
        onRemove: () => setState(() => _archivedOnly = false),
      ));
    }

    if (_selectedSort != 'Date Added (New to Old)') {
      chips.add(_buildFilterChip(
        label: 'Sort: $_selectedSort',
        onRemove: () => setState(() => _selectedSort = 'Date Added (New to Old)'),
      ));
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: const Border(
          bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: chips,
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onRemove,
  }) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: onRemove,
      backgroundColor: Colors.blue[100],
      deleteIconColor: Colors.blue[600],
      labelStyle: TextStyle(color: Colors.blue[800]),
    );
  }

  Widget _buildResultsSection() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Searching...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      );
    }

    if (!_hasSearched) {
      return _buildInitialState();
    }

    if (_searchResults.isEmpty) {
      return _buildNoResultsState();
    }

    return _buildResultsList();
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              Icons.search,
              size: 60,
              color: Colors.blue[300],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Search Your Links',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter keywords, select filters, and find\nexactly what you\'re looking for.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return EmptyStateWidget(
      icon: Icons.search_off,
      title: 'No results found',
      subtitle: 'Try adjusting your search terms or filters\nto find what you\'re looking for.',
      actionText: 'Clear Filters',
      onAction: _clearSearch,
    );
  }

  Widget _buildResultsList() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          // Results header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  size: 20,
                  color: Colors.blue[600],
                ),
                const SizedBox(width: 8),
                Text(
                  '${_searchResults.length} result${_searchResults.length == 1 ? '' : 's'} found',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  _selectedSort,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Results list
          Expanded(
            child: LinksListWidget(
              links: _searchResults,
              onTap: (link) {
                // Handle link tap
              },
              onDelete: (link) {
                // Handle delete
                setState(() {
                  _searchResults.removeWhere((l) => l.id == link.id);
                });
              },
              onToggleFavorite: (link) {
                // Handle favorite toggle - refresh results
                _performSearch();
              },
              onShare: (link) {
                // Handle share
              },
              fadeAnimation: _fadeAnimation,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  IconData _getSortIcon(String sortOption) {
    switch (sortOption) {
      case 'Date Added (New to Old)':
        return Icons.schedule;
      case 'Date Added (Old to New)':
        return Icons.history;
      case 'Most Visited':
        return Icons.trending_up;
      case 'Least Visited':
        return Icons.trending_down;
      case 'A-Z':
        return Icons.sort_by_alpha;
      case 'Z-A':
        return Icons.sort_by_alpha;
      default:
        return Icons.sort;
    }
  }

  int _getActiveFiltersCount() {
    int count = 0;
    if (_selectedCategory != null) count++;
    if (_selectedDateRange != null) count++;
    if (_favoritesOnly) count++;
    if (_archivedOnly) count++;
    if (_selectedSort != 'Date Added (New to Old)') count++;
    return count;
  }
}