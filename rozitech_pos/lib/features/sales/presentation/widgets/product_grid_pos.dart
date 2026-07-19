import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/local_file_helper.dart';
import '../../data/repositories/cart_repository.dart';

/// Product grid specifically for the POS screen.
/// Tap to add to cart with visual feedback.
class ProductGridPos extends ConsumerWidget {
  const ProductGridPos({super.key, required this.products});
  final List<Product> products;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 160,
        mainAxisExtent: 180,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: products.length,
      itemBuilder: (context, i) {
        return _PosProductCard(product: products[i])
            .animate()
            .fadeIn(delay: (i * 30).ms)
            .scale(begin: const Offset(0.9, 0.9));
      },
    );
  }
}

class _PosProductCard extends ConsumerStatefulWidget {
  const _PosProductCard({required this.product});
  final Product product;

  @override
  ConsumerState<_PosProductCard> createState() => _PosProductCardState();
}

class _PosProductCardState extends ConsumerState<_PosProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _tapController;
  bool _tapped = false;

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _tapController.dispose();
    super.dispose();
  }

  void _addToCart() {
    ref.read(cartProvider.notifier).addProduct(widget.product);
    setState(() => _tapped = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _tapped = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final product = widget.product;
    final outOfStock = product.trackStock && product.stock <= 0;

    return AnimatedScale(
      scale: _tapped ? 0.94 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: Material(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: outOfStock ? null : _addToCart,
          child: Opacity(
            opacity: outOfStock ? 0.5 : 1,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _tapped
                      ? cs.primary
                      : cs.outlineVariant,
                  width: _tapped ? 2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(13)),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _ProductImage(imagePath: product.imagePath),
                          if (_tapped)
                            Container(
                              color: cs.primary.withValues(alpha: 0.2),
                              child: const Icon(Icons.check_circle_rounded,
                                  color: Colors.white, size: 32),
                            ).animate().fadeIn(duration: 200.ms),
                        ],
                      ),
                    ),
                  ),

                  // Info
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          product.price.toCurrency(),
                          style: TextStyle(
                            color: cs.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (outOfStock)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Habis',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({this.imagePath});
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (imagePath != null && imagePath!.isNotEmpty) {
      return FutureBuilder<File>(
        future: LocalFileHelper.getFile(imagePath!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
            return Image.file(
              snapshot.data!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholder(cs),
            );
          }
          return Container(
            color: cs.surfaceContainerHighest,
            child: const Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        },
      );
    }
    return _placeholder(cs);
  }

  Widget _placeholder(ColorScheme cs) => Container(
        color: cs.surfaceContainerHighest,
        child: Icon(Icons.fastfood_rounded,
            size: 32, color: cs.onSurfaceVariant.withValues(alpha: 0.3)),
      );
}
