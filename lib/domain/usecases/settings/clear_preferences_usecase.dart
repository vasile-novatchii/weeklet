import 'package:weeklet/domain/repositories/settings_repository.dart';
import 'package:weeklet/domain/usecases/base/use_case.dart';

class ClearPreferencesUseCase implements UseCase<void, NoParams> {
  const ClearPreferencesUseCase(this._repository);

  final SettingsRepository _repository;

  @override
  Future<void> call(NoParams params) => _repository.clearPreferences();
}
