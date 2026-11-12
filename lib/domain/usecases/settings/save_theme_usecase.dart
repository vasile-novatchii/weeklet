import 'package:flutter/material.dart';
import 'package:weeklet/domain/repositories/settings_repository.dart';
import 'package:weeklet/domain/usecases/base/use_case.dart';

class SaveThemeUseCase implements UseCase<void, ThemeMode> {
  const SaveThemeUseCase(this._repository);

  final SettingsRepository _repository;

  @override
  Future<void> call(ThemeMode params) => _repository.saveTheme(params);
}
