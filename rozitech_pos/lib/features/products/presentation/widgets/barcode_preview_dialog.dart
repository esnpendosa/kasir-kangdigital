import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class BarcodePreviewDialog extends StatefulWidget {
  const BarcodePreviewDialog({
    super.key,
    required this.barcodeValue,
    required this.productName,
  });

  final String barcodeValue;
  final String productName;

  @override
  State<BarcodePreviewDialog> createState() => _BarcodePreviewDialogState();
}

class _BarcodePreviewDialogState extends State<BarcodePreviewDialog> {
  final _barcodeBoundaryKey = GlobalKey();
  final _qrBoundaryKey = GlobalKey();

  Future<void> _shareWidget(GlobalKey key, String filename) async {
    try {
      final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final bytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$filename.png');
      await file.writeAsBytes(bytes);
      await SharePlus.instance.share(ShareParams(files: [XFile(file.path)], text: 'Barcode / QR: ${widget.productName}'));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membagikan: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 2,
      child: AlertDialog(
        title: Text(widget.productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: SizedBox(
          width: 320,
          height: 280,
          child: Column(
            children: [
              TabBar(
                tabs: const [
                  Tab(text: 'Barcode'),
                  Tab(text: 'QR Code'),
                ],
                labelColor: cs.primary,
                unselectedLabelColor: cs.onSurface.withValues(alpha: 0.6),
                indicatorColor: cs.primary,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  children: [
                    // Barcode view
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RepaintBoundary(
                          key: _barcodeBoundaryKey,
                          child: Container(
                            color: Colors.white,
                            padding: const EdgeInsets.all(16),
                            child: BarcodeWidget(
                              barcode: Barcode.code128(),
                              data: widget.barcodeValue,
                              width: 240,
                              height: 100,
                              style: const TextStyle(fontSize: 14, color: Colors.black),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _shareWidget(_barcodeBoundaryKey, 'barcode_${widget.barcodeValue}'),
                          icon: const Icon(Icons.share_rounded, size: 18),
                          label: const Text('Bagikan Barcode'),
                        ),
                      ],
                    ),
                    // QR code view
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RepaintBoundary(
                          key: _qrBoundaryKey,
                          child: Container(
                            color: Colors.white,
                            padding: const EdgeInsets.all(16),
                            child: BarcodeWidget(
                              barcode: Barcode.qrCode(),
                              data: widget.barcodeValue,
                              width: 110,
                              height: 110,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _shareWidget(_qrBoundaryKey, 'qr_${widget.barcodeValue}'),
                          icon: const Icon(Icons.share_rounded, size: 18),
                          label: const Text('Bagikan QR Code'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}
