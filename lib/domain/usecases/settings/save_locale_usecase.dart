import 'package:flutter/material.dart';
import 'package:weeklet/domain/repositories/settings_repository.dart';
import 'package:weeklet/domain/usecases/base/use_case.dart';

class SaveLocaleUseCase implements UseCase<void, Locale?> {
  const SaveLocaleUseCase(this._repository);

  final SettingsRepository _repository;

  @override
  Future<void> call(Locale? params) => _repository.saveLocale(params);
}
