import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:weeklet/core/platform/export_file_store.dart';

class _FakePathProvider
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  _FakePathProvider(this.tempPath);

  final String tempPath;

  @override
  Future<String?> getTemporaryPath() async => tempPath;

  @override
  dynamic noSuchMethod(Invocation invocation) async => null;
}

void main() {
  late Directory tmp;

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('export_store_test');
    PathProviderPlatform.instance = _FakePathProvider(tmp.path);
  });

  tearDown(() => tmp.deleteSync(recursive: true));

  test('same file name never collides across exports', () async {
    final a = await ExportFileStore.write('weeklet_stats_2026.pdf', [1, 2]);
    final b = await ExportFileStore.write('weeklet_stats_2026.pdf', [3]);

    expect(a, isNot(b));
    expect(a.endsWith('/weeklet_stats_2026.pdf'), isTrue);
    expect(b.endsWith('/weeklet_stats_2026.pdf'), isTrue);
    expect(File(a).readAsBytesSync(), [1, 2]);
    expect(File(b).readAsBytesSync(), [3]);
    expect(a.startsWith(tmp.path), isTrue);
  });

  test('purge removes previous exports and tolerates none', () async {
    await ExportFileStore.purge();
    final a = await ExportFileStore.write('x.pdf', [1]);
    await ExportFileStore.purge();
    expect(File(a).existsSync(), isFalse);
  });
}
