import 'dart:async';
import 'package:flutter/material.dart';

import '../theme/home_colors.dart';
import '../theme/home_spacing.dart';
import '../theme/home_text_styles.dart';
import '../../store/models/product.model.dart';
import '../models/category.model.dart';

class HomeSearchSection extends StatefulWidget {
  final List<Product> allProducts;
  final List<Category> allCategories;
  final Function(String categoryId)? onCategorySelected;
  final Function(Product product)? onProductSelected;

  const HomeSearchSection({
    super.key,
    required this.allProducts,
    required this.allCategories,
    this.onCategorySelected,
    this.onProductSelected,
  });

  @override
  State<HomeSearchSection> createState() => _HomeSearchSectionState();
}

class _HomeSearchSectionState extends State<HomeSearchSection> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  final List<String> _hints = const [
    'Search for "Sugarcane"',
    'Search for "Coconut"',
    'Search for "Milk"',
    'Search for "Jaggery"',
  ];

  int _currentIndex = 0;
  Timer? _timer;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      if (_controller.text.isEmpty) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _hints.length;
        });
      }
    });

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) _hideOverlay();
    });
  }

  void _onChanged(String query) {
    setState(() => _isTyping = query.isNotEmpty);
    if (query.isNotEmpty) {
      _showOverlay();
    } else {
      _hideOverlay();
    }
  }

  void _showOverlay() {
    _hideOverlay();
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width - (HomeSpacing.md * 2),
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height - 5),
          child: Material(
            elevation: 12,
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 350),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: _buildSearchResults(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    final query = _controller.text.toLowerCase();
    
    final matchedCategories = widget.allCategories
        .where((c) => c.name.toLowerCase().contains(query))
        .toList();
        
    final matchedProducts = widget.allProducts
        .where((p) => p.name.toLowerCase().contains(query))
        .toList();

    if (matchedCategories.isEmpty && matchedProducts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Text("No items or categories found", style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      children: [
        if (matchedCategories.isNotEmpty) ...[
          _sectionHeader("Matching Categories"),
          ...matchedCategories.map((cat) => ListTile(
                dense: true,
                leading: const Icon(Icons.grid_view_rounded, size: 18, color: HomeColors.primaryGreen),
                title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  widget.onCategorySelected?.call(cat.id);
                  _controller.clear();
                  _onChanged('');
                  _focusNode.unfocus();
                },
              )),
        ],
        if (matchedProducts.isNotEmpty) ...[
          _sectionHeader("Products"),
          ...matchedProducts.map((prod) => ListTile(
                leading: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(image: NetworkImage(prod.mainImageUrl), fit: BoxFit.cover),
                  ),
                ),
                title: Text(prod.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                subtitle: Text("₹${prod.displayPrice.toInt()}", style: const TextStyle(color: HomeColors.primaryGreen, fontWeight: FontWeight.bold)),
                onTap: () {
                  widget.onProductSelected?.call(prod);
                  _hideOverlay();
                  _focusNode.unfocus();
                },
              )),
        ],
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[50],
      child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 0.5)),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    _hideOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: HomeSpacing.md,
        vertical: HomeSpacing.sm,
      ),
      child: Row(
        children: [
          /// 🔍 SEARCH BAR
          Expanded(
            child: CompositedTransformTarget(
              link: _layerLink,
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(HomeSpacing.radiusLg),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      onChanged: _onChanged,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.search,
                          color: HomeColors.textGrey,
                        ),
                        suffixIcon: _isTyping 
                          ? IconButton(
                              icon: const Icon(Icons.cancel, color: Colors.grey, size: 20),
                              onPressed: () {
                                _controller.clear();
                                _onChanged('');
                              },
                            )
                          : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),

                    /// Animated hint text (Only shows when controller is empty)
                    if (!_isTyping)
                      Positioned(
                        left: 48,
                        child: IgnorePointer(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            transitionBuilder: (child, animation) {
                              final fade = CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeInOut,
                              );
                              final slide = Tween<Offset>(
                                begin: const Offset(0, 0.15),
                                end: Offset.zero,
                              ).animate(fade);

                              return FadeTransition(
                                opacity: fade,
                                child: SlideTransition(
                                  position: slide,
                                  child: child,
                                ),
                              );
                            },
                            child: Text(
                              _hints[_currentIndex],
                              key: ValueKey(_hints[_currentIndex]),
                              style: HomeTextStyles.bodyGrey,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: HomeSpacing.sm),

          /// 🖼️ CANE POSTER
          ClipRRect(
            borderRadius: BorderRadius.circular(HomeSpacing.radiusLg),
            child: Image.asset(
              'assets/images/cane-poster.png',
              width: 75,
              height: 48,
              fit: BoxFit.fill,
            ),
          ),
        ],
      ),
    );
  }
}