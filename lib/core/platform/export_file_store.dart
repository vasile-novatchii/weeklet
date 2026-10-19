import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Persists exported PDFs in the temporary directory.
///
/// Every export is written to its own `exports/<uuid>/` subdirectory so that
/// re-exporting the same period can never overwrite a file the Android print
/// spooler is still reading. The custom file name is preserved.
class ExportFileStore {
  const ExportFileStore._();

  static const String _exportsDirName = 'exports';
  static const Uuid _uuid = Uuid();

  /// Writes [bytes] as [fileName] into a fresh unique directory and returns
  /// the file path.
  static Future<String> write(String fileName, List<int> bytes) async {
    final base = await getTemporaryDirectory();
    final dir = Directory('${base.path}/$_exportsDirName/${_uuid.v4()}');
    await dir.create(recursive: true);
    final filePath = '${dir.path}/$fileName';
    await File(filePath).writeAsBytes(bytes);
    return filePath;
  }

  /// Deletes all previous exports. Call at startup, when no print job can be
  /// reading them.
  static Future<void> purge() async {
    final base = await getTemporaryDirectory();
    final dir = Directory('${base.path}/$_exportsDirName');
    if (dir.existsSync()) {
      await dir.delete(recursive: true);
    }
  }
}
