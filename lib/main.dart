import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:weeklet/core/di/service_locator.dart' as di;
import 'package:weeklet/core/utils/locale_manager.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    final text = await rootBundle.loadString('assets/fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['Noto Sans'], text);
  });
  final locales = ui.PlatformDispatcher.instance.locales;
  final deviceLocale = locales.isNotEmpty
      ? locales.first
      : const Locale('en', 'US');
  LocaleManager().initialize(deviceLocale);

  await di.init();

  runApp(const WeekletApp());
}
