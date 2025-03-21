import '../../models/parameter.dart';
import '../../data/repositories/parameter_repository.dart';
import '../../data/repositories/parameter_repository_impl.dart';

class GetAllParametersUseCase {
  final ParameterRepository _parameterRepository = ParameterRepositoryImpl();

  Future<List<Parameter>> execute() async {
    // Здесь может быть бизнес-логика, например, кэширование результатов, фильтрация и т.д.
    return await _parameterRepository.getAllParameters();
  }
}