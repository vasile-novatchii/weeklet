import 'dart:convert';
import 'dart:io';

/// Reconstructs the visible text of a PDF whose text is drawn with embedded
/// TrueType fonts (Type0 / Identity-H). Glyph ids are hex-encoded in the
/// content stream, so the font's ToUnicode CMap is needed to decode them.
///
/// Coupled to the `pdf` package's output format (like `extractPdfText`).
String extractPdfUnicodeText(File pdfFile) {
  final bytes = pdfFile.readAsBytesSync();
  final text = latin1.decode(bytes, allowInvalid: true);

  // Inflate every FlateDecode stream, keyed by object number when known.
  final streamRe = RegExp(
    r'(\d+)\s+0\s+obj\s*<<([^>]*?/Filter\s*/FlateDecode[^>]*?)>>\s*stream\r?\n',
    dotAll: true,
  );
  final streams = <int, String>{};
  final ordered = <String>[];
  for (final m in streamRe.allMatches(text)) {
    final start = m.end;
    final end = text.indexOf('endstream', start);
    if (end == -1) continue;
    var rawEnd = end;
    while (rawEnd > start &&
        (bytes[rawEnd - 1] == 0x0a || bytes[rawEnd - 1] == 0x0d)) {
      rawEnd--;
    }
    try {
      final inflated = latin1.decode(zlib.decode(bytes.sublist(start, rawEnd)));
      streams[int.parse(m.group(1)!)] = inflated;
      ordered.add(inflated);
    } catch (_) {
      continue; // not every stream is decodable text - skip safely
    }
  }

  // Font resource name -> ToUnicode map.
  final fontMaps = <String, Map<int, String>>{};
  for (final obj in text.split('endobj')) {
    final tu = RegExp(r'/ToUnicode\s+(\d+)\s+0\s+R').firstMatch(obj);
    final name = RegExp(r'/Name\s*/(F\d+)').firstMatch(obj)?.group(1);
    if (tu == null || name == null) continue;
    final cmap = streams[int.parse(tu.group(1)!)];
    if (cmap != null) fontMaps[name] = _parseCMap(cmap);
  }

  final buffer = StringBuffer();
  final tokenRe = RegExp(
    r'/(F\d+)\s+[\d.]+\s+Tf|\[([^\]]*)\]\s*TJ|<([0-9a-fA-F]*)>\s*Tj',
  );
  for (final content in ordered) {
    Map<int, String>? current;
    for (final m in tokenRe.allMatches(content)) {
      if (m.group(1) != null) {
        current = fontMaps[m.group(1)!];
        continue;
      }
      if (current == null) continue;
      if (m.group(2) != null) {
        for (final h in RegExp(r'<([0-9a-fA-F]*)>').allMatches(m.group(2)!)) {
          buffer.write(_decode(h.group(1)!, current));
        }
      } else {
        buffer.write(_decode(m.group(3)!, current));
      }
      buffer.write(' ');
    }
  }
  return buffer.toString();
}

String _decode(String hex, Map<int, String> map) {
  final out = StringBuffer();
  for (var i = 0; i + 4 <= hex.length; i += 4) {
    out.write(map[int.parse(hex.substring(i, i + 4), radix: 16)] ?? '');
  }
  return out.toString();
}

String _utf16(String hex) {
  final units = <int>[];
  for (var i = 0; i + 4 <= hex.length; i += 4) {
    units.add(int.parse(hex.substring(i, i + 4), radix: 16));
  }
  return String.fromCharCodes(units);
}

Map<int, String> _parseCMap(String cmap) {
  final map = <int, String>{};
  for (final block in RegExp(
    r'beginbfchar(.*?)endbfchar',
    dotAll: true,
  ).allMatches(cmap)) {
    for (final p in RegExp(
      r'<([0-9a-fA-F]+)>\s*<([0-9a-fA-F]+)>',
    ).allMatches(block.group(1)!)) {
      map[int.parse(p.group(1)!, radix: 16)] = _utf16(p.group(2)!);
    }
  }
  for (final block in RegExp(
    r'beginbfrange(.*?)endbfrange',
    dotAll: true,
  ).allMatches(cmap)) {
    for (final p in RegExp(
      r'<([0-9a-fA-F]+)>\s*<([0-9a-fA-F]+)>\s*<([0-9a-fA-F]+)>',
    ).allMatches(block.group(1)!)) {
      final lo = int.parse(p.group(1)!, radix: 16);
      final hi = int.parse(p.group(2)!, radix: 16);
      final base = int.parse(p.group(3)!, radix: 16);
      for (var c = lo; c <= hi; c++) {
        map[c] = String.fromCharCode(base + (c - lo));
      }
    }
  }
  return map;
}
