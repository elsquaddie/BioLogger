import '../../models/parameter.dart';
import '../../data/repositories/parameter_repository.dart';
import '../../data/repositories/parameter_repository_impl.dart';

class UpdateParameterUseCase {
  final ParameterRepository _parameterRepository = ParameterRepositoryImpl();

  Future<int> execute(Parameter parameter) async {
    return await _parameterRepository.updateParameter(parameter); // Просто делегирование
  }
}