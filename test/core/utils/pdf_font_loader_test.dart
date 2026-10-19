import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weeklet/core/utils/pdf_font_loader.dart';

class _FakeBundle extends CachingAssetBundle {
  final List<String> requested = [];

  @override
  Future<ByteData> load(String key) async {
    requested.add(key);
    final value = key == PdfFontLoader.regularAssetPath ? 1 : 2;
    return ByteData.sublistView(Uint8List.fromList([value]));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('load returns regular and bold bytes from their asset keys', () async {
    final bundle = _FakeBundle();
    final fonts = await PdfFontLoader(bundle: bundle).load();

    expect(fonts.regular.getUint8(0), 1);
    expect(fonts.bold.getUint8(0), 2);
  });

  test('load hits the bundle once per asset key (cached)', () async {
    final bundle = _FakeBundle();
    final loader = PdfFontLoader(bundle: bundle);
    await loader.load();
    await loader.load();

    expect(bundle.requested, [
      PdfFontLoader.regularAssetPath,
      PdfFontLoader.boldAssetPath,
    ]);
  });

  test('default constructor loads the real bundled fonts', () async {
    final fonts = await PdfFontLoader().load();

    expect(fonts.regular.lengthInBytes, greaterThan(300000));
    expect(fonts.bold.lengthInBytes, greaterThan(300000));
  });
}
