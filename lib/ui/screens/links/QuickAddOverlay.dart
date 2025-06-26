import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuickAddOverlay extends StatefulWidget {
  final String sharedUrl;

  const QuickAddOverlay({
    Key? key,
    required this.sharedUrl,
  }) : super(key: key);

  @override
  State<QuickAddOverlay> createState() => _QuickAddOverlayState();
}

class _QuickAddOverlayState extends State<QuickAddOverlay>
    with SingleTickerProviderStateMixin {
  late TextEditingController _urlController;
  late TextEditingController _titleController;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  
  String selectedCategory = 'General';
  bool isSaving = false;
  
  final List<String> categories = [
    'General',
    'Work',
    'Personal',
    'Learning',
    'Social',
    'Shopping',
    'News',
    'Entertainment'
  ];

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: widget.sharedUrl);
    _titleController = TextEditingController();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
    _extractTitleFromUrl();
  }

  void _extractTitleFromUrl() {
    // Simple title extraction - you can enhance this
    try {
      final uri = Uri.parse(widget.sharedUrl);
      final domain = uri.host.replaceAll('www.', '');
      _titleController.text = 'Link from $domain';
    } catch (e) {
      _titleController.text = 'Shared Link';
    }
  }

  Future<void> _handleSave() async {
    if (_urlController.text.isEmpty || _titleController.text.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      // Simulate save operation
      await Future.delayed(const Duration(milliseconds: 500));
      _showSuccess();
      
      // Auto close after success
      Future.delayed(const Duration(milliseconds: 1500), () {
        _handleClose();
      });
      
    } catch (e) {
      _showError('Failed to save link');
      setState(() {
        isSaving = false;
      });
    }
  }

  void _showSuccess() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Link saved successfully!'),
          ],
        ),
        backgroundColor: Colors.grey[800],
        duration: Duration(milliseconds: 1500),
      ),
    );
  }

  void _showError(String message) {
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.grey[800],
      ),
    );
  }

  void _handleClose() {
    _animationController.reverse().then((_) {
       Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    _titleController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: _handleClose,
        child: Container(
          color: Colors.black54,
          child: GestureDetector(
            onTap: () {
              // Prevent closing when tapping on the sheet
            }, // Prevent closing when tapping on the sheet
            child: AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, MediaQuery.of(context).size.height * _slideAnimation.value),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      margin: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFF1A1B23),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Handle bar
                          Container(
                            margin: EdgeInsets.only(top: 12),
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[600],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          
                          Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFF4FC3F7),
                                            Color(0xFF29B6F6),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.link,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Quick Save Link',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            'Save to your collection',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: _handleClose,
                                      icon: Icon(Icons.close, color: Colors.white70),
                                    ),
                                  ],
                                ),
                                
                                SizedBox(height: 20),
                                
                                // URL Field
                                _buildTextField(
                                  controller: _urlController,
                                  label: 'URL',
                                  icon: Icons.link,
                                  maxLines: 2,
                                ),
                                
                                SizedBox(height: 16),
                                
                                // Title Field
                                _buildTextField(
                                  controller: _titleController,
                                  label: 'Title',
                                  icon: Icons.title,
                                ),
                                
                                SizedBox(height: 16),
                                
                                // Category Dropdown
                                _buildCategoryDropdown(),
                                
                                SizedBox(height: 24),
                                
                                // Save Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: isSaving ? null : _handleSave,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF4FC3F7),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: isSaving
                                        ? SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(
                                            'Save Link',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF2A2B35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white70),
          prefixIcon: Icon(icon, color: Colors.white70),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF2A2B35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedCategory,
        decoration: InputDecoration(
          labelText: 'Category',
          labelStyle: TextStyle(color: Colors.white70),
          prefixIcon: Icon(Icons.category, color: Colors.white70),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
        dropdownColor: Color(0xFF2A2B35),
        style: TextStyle(color: Colors.white),
        items: categories.map((category) {
          return DropdownMenuItem(
            value: category,
            child: Text(category),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              selectedCategory = value;
            });
          }
        },
      ),
    );
  }
}