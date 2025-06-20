import 'package:flutter/material.dart';
import 'package:clipo_app/models/Category.dart';

class CategoryDropdownWidget extends StatelessWidget {
  final List<CategoryModel> categories;
  final CategoryModel? selectedCategory;
  final ValueChanged<CategoryModel?> onChanged;
  final String? Function(CategoryModel?)? validator;
  final bool isLoading;
  final VoidCallback? onRetry;

  const CategoryDropdownWidget({
    Key? key,
    required this.categories,
    required this.selectedCategory,
    required this.onChanged,
    this.validator,
    this.isLoading = false,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: isLoading
          ? _buildLoadingState()
          : categories.isEmpty
              ? _buildEmptyState()
              : _buildDropdown(),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 60,
      padding: const EdgeInsets.all(16),
      child: const Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text('Loading categories...'),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 60,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.warning, color: Colors.orange[400], size: 20),
          const SizedBox(width: 12),
          const Text('No categories available'),
          const Spacer(),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
        ],
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<CategoryModel>(
      value: selectedCategory,
      validator: validator,
      hint: Row(
        children: [
          Icon(Icons.category, color: Colors.grey[400], size: 20),
          const SizedBox(width: 12),
          Text(
            'Select category',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
            ),
          ),
        ],
      ),
      decoration: const InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      isExpanded: true,
      items: categories.map((category) {
        return DropdownMenuItem<CategoryModel>(
          value: category,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _getCategoryColor(category.color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  _getCategoryIcon(category.icon),
                  color: _getCategoryColor(category.color),
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      category.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (category.description != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        category.description!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
      selectedItemBuilder: (BuildContext context) {
        return categories.map((category) {
          return Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _getCategoryColor(category.color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  _getCategoryIcon(category.icon),
                  color: _getCategoryColor(category.color),
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                category.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          );
        }).toList();
      },
      onChanged: onChanged,
    );
  }

  // Helper method to get icon from stored value
  IconData _getCategoryIcon(String? iconName) {
    switch (iconName?.toLowerCase()) {
      case 'computer':
        return Icons.computer;
      case 'palette':
        return Icons.palette;
      case 'business':
        return Icons.business;
      case 'school':
        return Icons.school;
      case 'movie':
        return Icons.movie;
      case 'health_and_safety':
        return Icons.health_and_safety;
      case 'flight':
        return Icons.flight;
      case 'restaurant':
        return Icons.restaurant;
      case 'sports_soccer':
        return Icons.sports_soccer;
      case 'newspaper':
        return Icons.newspaper;
      default:
        return Icons.category;
    }
  }

  // Helper method to get color from stored value
  Color _getCategoryColor(String? colorName) {
    switch (colorName?.toLowerCase()) {
      case 'blue':
        return Colors.blue;
      case 'purple':
        return Colors.purple;
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      case 'red':
        return Colors.red;
      case 'teal':
        return Colors.teal;
      case 'indigo':
        return Colors.indigo;
      case 'amber':
        return Colors.amber;
      case 'deeporange':
        return Colors.deepOrange;
      case 'bluegrey':
        return Colors.blueGrey;
      default:
        return Colors.grey;
    }
  }
}