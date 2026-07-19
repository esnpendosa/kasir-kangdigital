import 'dart:io';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/utils/invoice_generator.dart';
import '../../../../core/utils/local_file_helper.dart';
import '../../data/repositories/product_repository.dart';
import '../../../../core/widgets/barcode_scanner_widget.dart';
import '../widgets/barcode_preview_dialog.dart';

/// Add / Edit product form page.
class ProductFormPage extends ConsumerStatefulWidget {
  const ProductFormPage({super.key, this.productId});
  final int? productId;

  @override
  ConsumerState<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends ConsumerState<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _skuCtrl = TextEditingController();
  final _barcodeCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _minStockCtrl = TextEditingController();
  final _unitCtrl = TextEditingController(text: 'pcs');

  String? _imagePath;
  File? _imageFile;
  bool _isLoading = false;
  bool _isEdit = false;
  Product? _existing;

  @override
  void initState() {
    super.initState();
    _barcodeCtrl.addListener(() {
      if (mounted) setState(() {});
    });
    if (widget.productId != null) {
      _isEdit = true;
      _loadProduct();
    } else {
      _skuCtrl.text = InvoiceGenerator.shortId();
    }
  }

  Future<void> _loadProduct() async {
    final repo = ref.read(productRepositoryProvider);
    final product = await repo.getById(widget.productId!);
    if (product != null && mounted) {
      File? imgFile;
      if (product.imagePath != null && product.imagePath!.isNotEmpty) {
        imgFile = await LocalFileHelper.getFile(product.imagePath!);
      }
      setState(() {
        _existing = product;
        _nameCtrl.text = product.name;
        _skuCtrl.text = product.sku ?? '';
        _barcodeCtrl.text = product.barcode ?? '';
        _descCtrl.text = product.description ?? '';
        _priceCtrl.text = product.price.toStringAsFixed(0);
        _costCtrl.text = product.cost.toStringAsFixed(0);
        _stockCtrl.text = product.stock.toStringAsFixed(0);
        _minStockCtrl.text = product.minStock.toStringAsFixed(0);
        _unitCtrl.text = product.unit;
        _imagePath = product.imagePath;
        _imageFile = imgFile;
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _skuCtrl.dispose();
    _barcodeCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _costCtrl.dispose();
    _stockCtrl.dispose();
    _minStockCtrl.dispose();
    _unitCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pilih Sumber Foto',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.camera_alt_rounded, color: cs.primary),
                title: const Text('Ambil Foto Kamera'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: Icon(Icons.photo_library_rounded, color: cs.primary),
                title: const Text('Pilih dari Galeri'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (file != null) {
      setState(() {
        _imagePath = file.path;
        _imageFile = File(file.path);
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final repo = ref.read(productRepositoryProvider);

    String? finalImagePath = _imagePath;
    if (_imagePath != null && _imagePath != _existing?.imagePath) {
      // Save picked image permanently in product_images folder
      finalImagePath = await LocalFileHelper.saveImagePermanently(_imagePath!, 'product_images');
    }

    final companion = ProductsCompanion(
      id: _isEdit ? Value(_existing!.id) : const Value.absent(),
      name: Value(_nameCtrl.text.trim()),
      sku: Value(_skuCtrl.text.trim()),
      barcode: Value(_barcodeCtrl.text.trim()),
      description: Value(_descCtrl.text.trim()),
      imagePath: Value(finalImagePath),
      price: Value(double.tryParse(_priceCtrl.text) ?? 0),
      cost: Value(double.tryParse(_costCtrl.text) ?? 0),
      stock: Value(double.tryParse(_stockCtrl.text) ?? 0),
      minStock: Value(double.tryParse(_minStockCtrl.text) ?? 5),
      unit: Value(_unitCtrl.text.trim()),
      updatedAt: Value(DateTime.now()),
    );

    final result = _isEdit
        ? await repo.update(companion)
        : await repo.create(companion);

    setState(() => _isLoading = false);

    if (!mounted) return;

    result.fold(
      onSuccess: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEdit
                ? 'Produk berhasil diperbarui'
                : 'Produk berhasil ditambahkan'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      },
      onFailure: (msg, _) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Produk' : 'Tambah Produk'),
        actions: [
          if (_isEdit)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
              onPressed: _confirmDelete,
              tooltip: 'Hapus Produk',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image picker ─────────────────────────────────────────
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: cs.outlineVariant,
                          style: BorderStyle.solid,
                          width: 2),
                    ),
                    child: _imageFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.file(_imageFile!,
                                fit: BoxFit.cover),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_rounded,
                                  size: 40, color: cs.primary),
                              const SizedBox(height: 8),
                              Text('Pilih Foto',
                                  style: TextStyle(
                                      color: cs.primary, fontSize: 12)),
                            ],
                          ),
                  ),
                ).animate().fadeIn().scale(),
              ),

              const SizedBox(height: 24),
              _sectionTitle(context, 'Informasi Produk'),
              const SizedBox(height: 12),

              // Name
              _buildField(
                controller: _nameCtrl,
                label: 'Nama Produk *',
                icon: Icons.label_rounded,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              Row(children: [
                Expanded(
                  child: _buildField(
                    controller: _skuCtrl,
                    label: 'SKU',
                    icon: Icons.qr_code_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildField(
                    controller: _barcodeCtrl,
                    label: 'Barcode',
                    icon: Icons.barcode_reader,
                    suffix: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_barcodeCtrl.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.qr_code_rounded, size: 20),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => BarcodePreviewDialog(
                                  barcodeValue: _barcodeCtrl.text,
                                  productName: _nameCtrl.text.isEmpty ? 'Produk Baru' : _nameCtrl.text,
                                ),
                              );
                            },
                            tooltip: 'Generate Barcode/QR',
                          ),
                        IconButton(
                          icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
                          onPressed: () async {
                            final scanned = await BarcodeScannerWidget.scan(context);
                            if (scanned != null) {
                              setState(() {
                                _barcodeCtrl.text = scanned;
                              });
                            }
                          },
                          tooltip: 'Scan barcode',
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 12),

              _buildField(
                controller: _descCtrl,
                label: 'Deskripsi',
                icon: Icons.notes_rounded,
                maxLines: 3,
              ),

              const SizedBox(height: 24),
              _sectionTitle(context, 'Harga & Stok'),
              const SizedBox(height: 12),

              Row(children: [
                Expanded(
                  child: _buildField(
                    controller: _priceCtrl,
                    label: 'Harga Jual *',
                    icon: Icons.sell_rounded,
                    keyboardType: TextInputType.number,
                    prefix: const Text('Rp '),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Harga wajib diisi' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildField(
                    controller: _costCtrl,
                    label: 'Harga Beli',
                    icon: Icons.shopping_bag_outlined,
                    keyboardType: TextInputType.number,
                    prefix: const Text('Rp '),
                  ),
                ),
              ]),
              const SizedBox(height: 12),

              Row(children: [
                Expanded(
                  child: _buildField(
                    controller: _stockCtrl,
                    label: 'Stok Awal',
                    icon: Icons.inventory_rounded,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildField(
                    controller: _minStockCtrl,
                    label: 'Stok Minimum',
                    icon: Icons.warning_amber_rounded,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildField(
                    controller: _unitCtrl,
                    label: 'Satuan',
                    icon: Icons.straighten_rounded,
                  ),
                ),
              ]),

              const SizedBox(height: 32),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _save,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(_isLoading
                      ? 'Menyimpan...'
                      : _isEdit
                          ? 'Perbarui Produk'
                          : 'Simpan Produk'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .titleSmall
          ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.5),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
    Widget? prefix,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18),
        prefixText: prefix is Text ? prefix.data : null,
        suffixIcon: suffix,
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Produk?'),
        content: Text('Yakin ingin menghapus "${_existing?.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child:
                const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final repo = ref.read(productRepositoryProvider);
      await repo.softDelete(_existing!.id);
      if (mounted) context.pop();
    }
  }
}
