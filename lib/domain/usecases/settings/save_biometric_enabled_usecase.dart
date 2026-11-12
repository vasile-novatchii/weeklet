import 'package:weeklet/domain/repositories/settings_repository.dart';
import 'package:weeklet/domain/usecases/base/use_case.dart';

class SaveBiometricEnabledParams {
  const SaveBiometricEnabledParams({required this.enabled});

  final bool enabled;
}

class SaveBiometricEnabledUseCase
    implements UseCase<void, SaveBiometricEnabledParams> {
  const SaveBiometricEnabledUseCase(this._repository);

  final SettingsRepository _repository;

  @override
  Future<void> call(SaveBiometricEnabledParams params) =>
      _repository.saveBiometricEnabled(enabled: params.enabled);
}
