import 'package:flutter/material.dart';

import '../models/product.model.dart';

import '../../home/theme/home_colors.dart';
import '../../home/theme/home_spacing.dart';
import '../../home/theme/home_text_styles.dart';

import '../widgets/product_add_button.dart';
import '../widgets/product_image_gallery.dart';
import '../widgets/product_price_view.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;
  final String outletId;

  const ProductDetailsScreen({
    super.key,
    required this.product,
    required this.outletId,
  });

  @override
  State<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState
    extends State<ProductDetailsScreen> {
  late Product _product;

  /* ================================================= */
  /* INIT ⭐ SIMPLIFIED (NO SOCKETS)                    */
  /* ================================================= */

  @override
  void initState() {
    super.initState();

    _product = widget.product;

    debugPrint(
      '🛒 ProductDetails → opened product: ${_product.name}',
    );
  }

  /* ================================================= */
  /* UI                                                */
  /* ================================================= */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomeColors.pureWhite,

      appBar: AppBar(
        backgroundColor: HomeColors.greenPastry,
        elevation: 0,
        centerTitle: true,
        title: Text(
          _product.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: HomeTextStyles.sectionTitle,
        ),
        iconTheme: const IconThemeData(
          color: HomeColors.primaryGreen,
        ),
      ),

      body: CustomScrollView(
        slivers: [
          /* ================= IMAGES ================= */

          SliverToBoxAdapter(
            child: ProductImageGallery(
              key: ValueKey(_product.mainImageUrl),
              mainImageUrl: _product.mainImageUrl,
              galleryImageUrls: _product.galleryImageUrls,
            ),
          ),

          /* ================= CONTENT ================= */

          SliverPadding(
            padding: const EdgeInsets.all(HomeSpacing.md),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _HeaderSection(product: _product),

                const SizedBox(height: HomeSpacing.sm),

                _PriceSection(product: _product),

                const SizedBox(height: HomeSpacing.md),

                _TagSection(product: _product),

                const SizedBox(height: HomeSpacing.lg),

                _DescriptionSection(product: _product),

                const SizedBox(height: 120),
              ]),
            ),
          ),
        ],
      ),

      /* ================= BOTTOM BAR ================= */

      bottomNavigationBar:
          _BottomAddBar(product: _product),
    );
  }
}

/* ================================================= */
/* HEADER                                            */
/* ================================================= */

class _HeaderSection extends StatelessWidget {
  final Product product;

  const _HeaderSection({required this.product});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.category.name,
                style: HomeTextStyles.bodyGrey,
              ),
              const SizedBox(height: 4),
              Text(
                product.name,
                style: HomeTextStyles.offerTitle,
              ),
            ],
          ),
        ),
        if (product.isTrending)
          const Icon(
            Icons.local_fire_department,
            color: Colors.red,
          ),
      ],
    );
  }
}

/* ================================================= */
/* PRICE                                             */
/* ================================================= */

class _PriceSection extends StatelessWidget {
  final Product product;

  const _PriceSection({required this.product});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ProductPriceView(
          product: product,
          showDiscountText: true,
        ),
        const SizedBox(width: 8),
        Text(
          '${product.unit.value} ${product.unit.type}',
          style: HomeTextStyles.bodyGrey,
        ),
      ],
    );
  }
}

/* ================================================= */
/* TAGS                                              */
/* ================================================= */

class _TagSection extends StatelessWidget {
  final Product product;

  const _TagSection({required this.product});

  @override
  Widget build(BuildContext context) {
    if (product.tags.isEmpty) return const SizedBox();

    return Wrap(
      spacing: 6,
      children: product.tags
          .map((e) => Chip(label: Text(e)))
          .toList(),
    );
  }
}

/* ================================================= */
/* DESCRIPTION                                       */
/* ================================================= */

class _DescriptionSection extends StatelessWidget {
  final Product product;

  const _DescriptionSection({required this.product});

  @override
  Widget build(BuildContext context) {
    final text =
        product.longDescription ??
            product.shortDescription;

    if (text == null) return const SizedBox();

    return Text(
      text,
      style: HomeTextStyles.bodyGrey,
    );
  }
}

/* ================================================= */
/* BOTTOM BAR                                        */
/* ================================================= */

class _BottomAddBar extends StatelessWidget {
  final Product product;

  const _BottomAddBar({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(HomeSpacing.md),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          ProductPriceView(
            product: product,
            showDiscountText: true,
          ),
          const ProductAddButton(),
        ],
      ),
    );
  }
}
