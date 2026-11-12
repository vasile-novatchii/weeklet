import 'package:flutter/services.dart';

/// Loads the bundled Noto Sans TTF bytes for the stats PDF.
///
/// Lives in core so the domain layer receives plain [ByteData] and stays
/// free of Flutter dependencies. Bytes are loaded once and cached.
class PdfFontLoader {
  PdfFontLoader({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  static const String regularAssetPath = 'assets/fonts/NotoSans-Regular.ttf';
  static const String boldAssetPath = 'assets/fonts/NotoSans-Bold.ttf';

  final AssetBundle _bundle;
  ({ByteData regular, ByteData bold})? _cache;

  /// Returns regular and bold font bytes, loading them on first call only.
  Future<({ByteData regular, ByteData bold})> load() async {
    final cached = _cache;
    if (cached != null) {
      return cached;
    }
    final regular = await _bundle.load(regularAssetPath);
    final bold = await _bundle.load(boldAssetPath);
    return _cache = (regular: regular, bold: bold);
  }
}
