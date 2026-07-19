/// Converts a static QRIS string into a valid dynamic QRIS payload
/// following the EMVCo Merchant Presented Mode (MPM) / QRIS Indonesia standard.
///
/// Reference:
/// - QRIS Indonesia: https://qris.id/homepage/pojok-qris.php
/// - EMVCo MPM spec: https://www.emvco.com/emv-technologies/qrcodes/
///
/// Key fields in QRIS:
///   00 - Payload Format Indicator  ("000201")
///   01 - Point of Initiation       ("010211" = static, "010212" = dynamic)
///   26-51 - Merchant Account Info  (nested TLV)
///   52 - Merchant Category Code
///   53 - Transaction Currency
///   54 - Transaction Amount         (ONLY in dynamic QRIS)
///   58 - Country Code
///   59 - Merchant Name
///   60 - Merchant City
///   61 - Postal Code
///   62 - Additional Data
///   63 - CRC-16/CCITT-FALSE (4 hex chars)
///
/// Usage:
///   final dynamicQris = QrisDynamicConverter.convert(staticQrisString, 75000);
class QrisDynamicConverter {
  QrisDynamicConverter._();

  /// Converts [baseQris] (a static QRIS string) into a dynamic QRIS
  /// with [amount] as the transaction amount.
  ///
  /// Throws [ArgumentError] if the input is not a valid QRIS string.
  static String convert(String baseQris, double amount) {
    final trimmed = baseQris.trim();

    if (!_isValidQris(trimmed)) {
      throw ArgumentError(
        'String QRIS tidak valid.\n'
        'Pastikan NMID adalah kode QRIS lengkap (diawali 000201, diakhiri 6304XXXX).',
      );
    }

    // Strip CRC trailer — always the last 8 chars: "6304XXXX"
    final crcIdx = trimmed.lastIndexOf('6304');
    if (crcIdx == -1 || crcIdx < trimmed.length - 8) {
      throw ArgumentError('CRC field (6304) tidak ditemukan di akhir QRIS.');
    }

    String body = trimmed.substring(0, crcIdx);

    // ── 1. Set Point of Initiation to "12" (dynamic) ─────────────────────
    // Tag 01 is exactly at byte offset 6: "000201" then "01" "02" "11"
    // Replace only the first occurrence at the very beginning of the string
    // to avoid replacing matching bytes inside Merchant Account Info payloads.
    if (body.startsWith('000201010211')) {
      body = '000201010212' + body.substring('000201010211'.length);
    } else if (body.startsWith('000201010212')) {
      // already dynamic — leave as-is
    } else {
      // Graceful fallback: find "010211" within the first 20 chars only
      final initIdx = body.indexOf('010211');
      if (initIdx != -1 && initIdx <= 8) {
        body = body.substring(0, initIdx) +
            '010212' +
            body.substring(initIdx + 6);
      }
    }

    // ── 2. Remove any existing Tag 54 (transaction amount) ───────────────
    body = _removeTlv(body, '54');

    // ── 3. Build Tag 54 value ─────────────────────────────────────────────
    // QRIS spec: amount in IDR should be integer-only (no decimal for Rupiah)
    // If the amount has fractional part, keep 2 decimal places; otherwise integer.
    final String amountValue;
    if (amount == amount.truncateToDouble()) {
      amountValue = amount.toInt().toString();
    } else {
      amountValue = amount.toStringAsFixed(2);
    }
    final amountLen = amountValue.length.toString().padLeft(2, '0');
    final tag54 = '54$amountLen$amountValue';

    // ── 4. Insert Tag 54 before Tag 58 (Country Code) ────────────────────
    // Per QRIS Indonesia spec, Tag 54 must appear before Tag 58.
    final tag58Idx = body.indexOf('5802');
    if (tag58Idx != -1) {
      body = body.substring(0, tag58Idx) + tag54 + body.substring(tag58Idx);
    } else {
      body += tag54;
    }

    // ── 5. Append CRC placeholder and compute CRC-16/CCITT-FALSE ─────────
    body += '6304';
    final crc = _crc16Ccitt(body);
    final crcHex = crc.toRadixString(16).toUpperCase().padLeft(4, '0');

    return body + crcHex;
  }

  /// Quick sanity check — does this look like a QRIS string?
  static bool isValid(String qris) => _isValidQris(qris.trim());

  /// Parse and return the merchant name from a QRIS string (Tag 59).
  static String? getMerchantName(String qris) {
    final t = qris.trim();
    return _extractTag(t, '59');
  }

  /// Parse and return the merchant city from a QRIS string (Tag 60).
  static String? getMerchantCity(String qris) {
    final t = qris.trim();
    return _extractTag(t, '60');
  }

  // ── Internal ─────────────────────────────────────────────────────────────

  static bool _isValidQris(String s) {
    return s.startsWith('000201') &&
        s.contains('6304') &&
        s.length >= 30;
  }

  /// Remove the first occurrence of TLV with [tag] from the payload body.
  static String _removeTlv(String body, String tag) {
    final result = StringBuffer();
    int i = 0;
    while (i < body.length) {
      if (i + 4 > body.length) {
        result.write(body.substring(i));
        break;
      }
      final t = body.substring(i, i + 2);
      final lenStr = body.substring(i + 2, i + 4);
      final len = int.tryParse(lenStr);
      if (len == null || i + 4 + len > body.length) {
        result.write(body.substring(i));
        break;
      }
      if (t == tag) {
        // skip this tag
        i += 4 + len;
        continue;
      }
      result.write(body.substring(i, i + 4 + len));
      i += 4 + len;
    }
    return result.toString();
  }

  /// Extract value of a top-level TLV tag.
  static String? _extractTag(String body, String tag) {
    int i = 0;
    while (i < body.length) {
      if (i + 4 > body.length) break;
      final t = body.substring(i, i + 2);
      final lenStr = body.substring(i + 2, i + 4);
      final len = int.tryParse(lenStr);
      if (len == null || i + 4 + len > body.length) break;
      if (t == tag) {
        return body.substring(i + 4, i + 4 + len);
      }
      i += 4 + len;
    }
    return null;
  }

  /// CRC-16/CCITT-FALSE — polynomial 0x1021, initial value 0xFFFF.
  /// This is the exact algorithm specified by EMVCo for QRIS CRC calculation.
  static int _crc16Ccitt(String data) {
    int crc = 0xFFFF;
    for (int i = 0; i < data.length; i++) {
      crc ^= (data.codeUnitAt(i) & 0xFF) << 8;
      for (int b = 0; b < 8; b++) {
        if ((crc & 0x8000) != 0) {
          crc = ((crc << 1) ^ 0x1021) & 0xFFFF;
        } else {
          crc = (crc << 1) & 0xFFFF;
        }
      }
    }
    return crc;
  }
}
