import 'package:weeklet/domain/entities/settings.dart';
import 'package:weeklet/domain/repositories/settings_repository.dart';
import 'package:weeklet/domain/usecases/base/use_case.dart';

class GetSettingsUseCase implements UseCase<Settings, NoParams> {
  const GetSettingsUseCase(this._repository);

  final SettingsRepository _repository;

  @override
  Future<Settings> call(NoParams params) => _repository.getSettings();
}
