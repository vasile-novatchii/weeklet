import 'package:weeklet/domain/repositories/settings_repository.dart';
import 'package:weeklet/domain/usecases/base/use_case.dart';

class SaveCurrencyUseCase implements UseCase<void, String> {
  const SaveCurrencyUseCase(this._repository);

  final SettingsRepository _repository;

  @override
  Future<void> call(String params) => _repository.saveCurrency(params);
}
