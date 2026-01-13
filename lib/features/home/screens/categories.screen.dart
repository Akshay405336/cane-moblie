import 'package:flutter/material.dart';

import '../models/category.model.dart';
import '../services/category_socket_service.dart';
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

  // 🔥 SUBSCRIBE FIRST
  CategorySocketService.subscribe(_onCategories);

  // ✅ USE CACHED DATA IMMEDIATELY (NO SHIMMER)
  final cached =
      CategorySocketService.cachedCategories;

  if (cached.isNotEmpty) {
    _categories = cached;
    _loading = false;
  } else {
    // 🔌 CONNECT ONLY IF NEEDED
    CategorySocketService.connect();
  }

  // 🛟 SAFETY TIMEOUT
  Future.delayed(const Duration(seconds: 10), () {
    if (!mounted) return;
    if (_loading) {
      setState(() {
        _loading = false;
      });
    }
  });
}


  @override
  void dispose() {
    CategorySocketService.unsubscribe(_onCategories);
    super.dispose();
  }

  /* -------------------------------------------------- */
  /* SOCKET HANDLER                                     */
  /* -------------------------------------------------- */

  void _onCategories(List<Category> categories) {
    if (!mounted) return;

    setState(() {
      _categories = categories;
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
          : _categories.isEmpty
              ? const Center(
                  child: Text(
                    'No categories available',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                )
              : Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    /// Horizontal categories
                    CategoryListWidget(
                      categories: _categories,
                    ),

                    const SizedBox(height: 24),

                    /// Vertical list
                    Expanded(
                      child: ListView.separated(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        itemCount:
                            _categories.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(
                                height: 12),
                        itemBuilder:
                            (context, index) {
                          final category =
                              _categories[index];

                          return ListTile(
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          12),
                            ),
                            tileColor:
                                Colors.grey.shade100,
                            leading: const Icon(
                              Icons.category,
                            ),
                            title: Text(
                              category.name,
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
