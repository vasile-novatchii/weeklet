import 'package:weeklet/domain/entities/category.dart';
import 'package:weeklet/domain/repositories/category_repository.dart';
import 'package:weeklet/domain/usecases/base/use_case.dart';

class GetAllCategoriesUseCase implements UseCase<List<Category>, NoParams> {
  GetAllCategoriesUseCase(this.repository);

  final CategoryRepository repository;

  @override
  Future<List<Category>> call(NoParams params) => repository.getAllCategories();
}
