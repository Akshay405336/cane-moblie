import 'package:flutter/material.dart';

import '../models/category.model.dart';
import '../services/category_api.dart';
import '../services/category_socket.service.dart';
import '../widgets/category_list.widget.dart';
import '../widgets/category_shimmer.widget.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() =>
      _CategoriesScreenState();
}

class _CategoriesScreenState
    extends State<CategoriesScreen> {
  List<Category> _categories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();

    // 🔌 SOCKET AUTO REFRESH
    CategorySocketService.connect(
      onUpdate: _loadCategories,
    );
  }

  @override
  void dispose() {
    CategorySocketService.disconnect();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final data = await CategoryApi.getAll();
    if (!mounted) return;
    setState(() {
      _categories = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        centerTitle: true,
      ),
      body: _loading
          ? const CategoryShimmer()
          : Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                /// reuse same widget (horizontal)
                CategoryListWidget(
                  categories: _categories,
                ),

                const SizedBox(height: 24),

                /// Vertical list (full view)
                Expanded(
                  child: ListView.separated(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final category =
                          _categories[index];

                      return ListTile(
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                                  12),
                        ),
                        tileColor:
                            Colors.grey.shade100,
                        leading: const Icon(
                          Icons.category,
                        ),
                        title: Text(
                          category.name,
                          style: const TextStyle(
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                        onTap: () {
                          // 🔜 future: open category products
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
