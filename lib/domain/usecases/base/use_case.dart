abstract class UseCase<UseCaseType, Params> {
  Future<UseCaseType> call(
    Params params,
  );
}

/// Use 'NoParams' for no arguments Use Case
class NoParams {}
