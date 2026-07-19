import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/utils/extensions.dart';
import '../../../products/data/repositories/product_repository.dart';
import '../../data/repositories/cart_repository.dart';
import '../widgets/cart_panel.dart';
import '../widgets/product_grid_pos.dart';

class PosPage extends ConsumerStatefulWidget {
  const PosPage({super.key});

  @override
  ConsumerState<PosPage> createState() => _PosPageState();
}

class _PosPageState extends ConsumerState<PosPage> {
  bool _showCart = false;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 768;
    final cart = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: isWide
            ? _WideLayout(cartState: cart)
            : _NarrowLayout(
                cartState: cart,
                showCart: _showCart,
                onToggleCart: () => setState(() => _showCart = !_showCart),
              ),
      ),
    );
  }
}

// ─── Wide layout ──────────────────────────────────────────────────────────────
class _WideLayout extends ConsumerWidget {
  const _WideLayout({required this.cartState});
  final CartState cartState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(flex: 6, child: _ProductSection()),
        VerticalDivider(width: 1, color: Theme.of(context).colorScheme.outlineVariant),
        SizedBox(width: 380, child: CartPanel(cartState: cartState)),
      ],
    );
  }
}

// ─── Narrow layout ────────────────────────────────────────────────────────────
class _NarrowLayout extends ConsumerWidget {
  const _NarrowLayout({
    required this.cartState,
    required this.showCart,
    required this.onToggleCart,
  });
  final CartState cartState;
  final bool showCart;
  final VoidCallback onToggleCart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return Stack(
      children: [
        _ProductSection(),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.extended(
            onPressed: onToggleCart,
            icon: const Icon(Icons.shopping_cart_rounded),
            label: Text(cartState.totalItems > 0
                ? '${cartState.totalItems} item • ${cartState.total.toCurrency()}'
                : 'Keranjang'),
            backgroundColor: cs.primary,
            foregroundColor: Colors.white,
          ),
        ),
        if (showCart)
          Positioned.fill(
            child: GestureDetector(
              onTap: onToggleCart,
              child: Container(color: Colors.black54),
            ),
          ),
        if (showCart)
          Positioned(
            bottom: 0, left: 0, right: 0,
            height: MediaQuery.sizeOf(context).height * 0.75,
            child: Material(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: CartPanel(cartState: cartState),
            ).animate().slideY(begin: 1, curve: Curves.easeOutCubic),
          ),
      ],
    );
  }
}

// ─── Product section ──────────────────────────────────────────────────────────
class _ProductSection extends ConsumerStatefulWidget {
  @override
  ConsumerState<_ProductSection> createState() => _ProductSectionState();
}

class _ProductSectionState extends ConsumerState<_ProductSection> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final search = ref.watch(posSearchProvider);
    final productsAsync = ref.watch(
      productsStreamProvider((search: search, categoryId: null)),
    );
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          color: cs.surface,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('Kasir',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w800)),
                  ),
                  // Barcode scan button
                  IconButton(
                    icon: const Icon(Icons.qr_code_scanner_rounded),
                    tooltip: 'Scan Barcode',
                    onPressed: () => _openBarcodeScanner(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _searchCtrl,
                onChanged: (v) =>
                    ref.read(posSearchProvider.notifier).state = v,
                decoration: InputDecoration(
                  hintText: 'Cari produk atau scan barcode...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: search.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchCtrl.clear();
                            ref.read(posSearchProvider.notifier).state = '';
                          })
                      : null,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: cs.outlineVariant),

        // Product grid
        Expanded(
          child: productsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (products) {
              if (products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search_off_rounded,
                          size: 48,
                          color: cs.onSurface.withValues(alpha: 0.3)),
                      const SizedBox(height: 12),
                      Text('Produk tidak ditemukan',
                          style: TextStyle(
                              color: cs.onSurface.withValues(alpha: 0.5))),
                    ],
                  ),
                );
              }
              return ProductGridPos(products: products);
            },
          ),
        ),
      ],
    );
  }

  Future<void> _openBarcodeScanner(BuildContext context) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _BarcodeScannerSheet(),
    );

    if (result == null || result.isEmpty) return;

    // Look up product by barcode
    final repo = ref.read(productRepositoryProvider);
    final product = await repo.getByBarcode(result);

    if (!mounted) return;

    if (product == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Produk dengan barcode "$result" tidak ditemukan'),
          backgroundColor: Colors.orange,
          action: SnackBarAction(
            label: 'Cari Manual',
            onPressed: () {
              _searchCtrl.text = result;
              ref.read(posSearchProvider.notifier).state = result;
            },
          ),
        ),
      );
    } else {
      // Add to cart
      ref.read(cartProvider.notifier).addProduct(product);
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${product.name} ditambahkan ke keranjang',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }
}

// ─── Barcode Scanner Bottom Sheet ─────────────────────────────────────────────
class _BarcodeScannerSheet extends StatefulWidget {
  const _BarcodeScannerSheet();

  @override
  State<_BarcodeScannerSheet> createState() => _BarcodeScannerSheetState();
}

class _BarcodeScannerSheetState extends State<_BarcodeScannerSheet> {
  MobileScannerController? _controller;
  bool _isFlashOn = false;
  bool _scanned = false;
  bool _isFrontCamera = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final raw = barcodes.first.rawValue;
    if (raw == null || raw.isEmpty) return;

    setState(() => _scanned = true);
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop(raw);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.75,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle + header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.white38,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Scan Barcode Produk',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                // Flash toggle
                IconButton(
                  icon: Icon(
                    _isFlashOn ? Icons.flash_on : Icons.flash_off,
                    color: _isFlashOn ? Colors.yellow : Colors.white54,
                  ),
                  onPressed: () {
                    setState(() => _isFlashOn = !_isFlashOn);
                    _controller?.toggleTorch();
                  },
                ),
                // Switch camera
                IconButton(
                  icon: const Icon(Icons.cameraswitch_rounded,
                      color: Colors.white54),
                  onPressed: () {
                    setState(() => _isFrontCamera = !_isFrontCamera);
                    _controller?.switchCamera();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white54),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Camera view with overlay
          Expanded(
            child: Stack(
              children: [
                MobileScanner(
                  controller: _controller!,
                  onDetect: _onDetect,
                ),
                // Scan overlay
                _ScanOverlay(),
              ],
            ),
          ),

          // Manual input option
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.black,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Arahkan kamera ke barcode produk',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                // Manual barcode entry
                Row(
                  children: [
                    Expanded(
                      child: _ManualBarcodeInput(
                        onSubmit: (value) {
                          if (value.isNotEmpty && !_scanned) {
                            setState(() => _scanned = true);
                            Navigator.of(context).pop(value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Scan Overlay ─────────────────────────────────────────────────────────────
class _ScanOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ScanOverlayPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _ScanOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    const double cutoutSize = 240;
    final cutoutLeft = (size.width - cutoutSize) / 2;
    final cutoutTop = (size.height - cutoutSize) / 2;
    final cutoutRect = Rect.fromLTWH(cutoutLeft, cutoutTop, cutoutSize, cutoutSize);

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(cutoutRect, const Radius.circular(12)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    // Corner markers
    final cornerPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    const cLen = 24.0;
    final r = cutoutRect;

    // Top-left
    canvas.drawPath(Path()
      ..moveTo(r.left, r.top + cLen)
      ..lineTo(r.left, r.top)
      ..lineTo(r.left + cLen, r.top), cornerPaint);
    // Top-right
    canvas.drawPath(Path()
      ..moveTo(r.right - cLen, r.top)
      ..lineTo(r.right, r.top)
      ..lineTo(r.right, r.top + cLen), cornerPaint);
    // Bottom-left
    canvas.drawPath(Path()
      ..moveTo(r.left, r.bottom - cLen)
      ..lineTo(r.left, r.bottom)
      ..lineTo(r.left + cLen, r.bottom), cornerPaint);
    // Bottom-right
    canvas.drawPath(Path()
      ..moveTo(r.right - cLen, r.bottom)
      ..lineTo(r.right, r.bottom)
      ..lineTo(r.right, r.bottom - cLen), cornerPaint);

    // Scan line animation effect (static)
    final linePaint = Paint()
      ..color = Colors.green.withValues(alpha: 0.6)
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(r.left + 8, r.top + r.height / 2),
      Offset(r.right - 8, r.top + r.height / 2),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─── Manual Barcode Input ─────────────────────────────────────────────────────
class _ManualBarcodeInput extends StatefulWidget {
  const _ManualBarcodeInput({required this.onSubmit});
  final ValueChanged<String> onSubmit;

  @override
  State<_ManualBarcodeInput> createState() => _ManualBarcodeInputState();
}

class _ManualBarcodeInputState extends State<_ManualBarcodeInput> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _ctrl,
      style: const TextStyle(color: Colors.white),
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Ketik barcode manual...',
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        suffixIcon: IconButton(
          icon: const Icon(Icons.search_rounded, color: Colors.white70),
          onPressed: () => widget.onSubmit(_ctrl.text.trim()),
        ),
      ),
      onSubmitted: (v) => widget.onSubmit(v.trim()),
    );
  }
}
