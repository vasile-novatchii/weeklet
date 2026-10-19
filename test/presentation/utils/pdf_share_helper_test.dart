import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:weeklet/presentation/utils/pdf_share_helper.dart';

void main() {
  const path = '/tmp/some/dir/weeklet_stats_2026.pdf';

  test('XFile carries path and application/pdf mime type', () {
    final params = PdfShareHelper.buildParams(filePath: path, subject: 's');
    expect(params.files!.single.path, path);
    expect(params.files!.single.mimeType, 'application/pdf');
    expect(params.files!.single.name, 'weeklet_stats_2026.pdf');
  });

  test('fileNameOverrides equals basename', () {
    final params = PdfShareHelper.buildParams(filePath: path, subject: 's');
    expect(params.fileNameOverrides, ['weeklet_stats_2026.pdf']);
  });

  test('subject and sharePositionOrigin preserved', () {
    final params = PdfShareHelper.buildParams(
      filePath: path,
      subject: 'My subject',
    );
    expect(params.subject, 'My subject');
    expect(params.sharePositionOrigin, const Rect.fromLTWH(0, 0, 1, 1));
  });
}
