import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/product_repository.dart';

/// Search bar for products with state controller.
class ProductFilterBar extends ConsumerStatefulWidget {
  const ProductFilterBar({super.key});

  @override
  ConsumerState<ProductFilterBar> createState() => _ProductFilterBarState();
}

class _ProductFilterBarState extends ConsumerState<ProductFilterBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final search = ref.read(productSearchProvider);
    _controller = TextEditingController(text: search);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final search = ref.watch(productSearchProvider);

    // Sync search clearing/external updates
    if (search != _controller.text) {
      _controller.text = search;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            onChanged: (v) =>
                ref.read(productSearchProvider.notifier).state = v,
            decoration: InputDecoration(
              hintText: 'Cari nama, SKU, barcode...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: search.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        ref.read(productSearchProvider.notifier).state = '';
                        _controller.clear();
                      },
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
