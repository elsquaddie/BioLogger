import '../../models/parameter.dart';
import '../../data/repositories/parameter_repository.dart';
import '../../data/repositories/parameter_repository_impl.dart';

class GetParameterUseCase {
  final ParameterRepository _parameterRepository = ParameterRepositoryImpl();

  Future<Parameter?> execute(int parameterId) async {
    return await _parameterRepository.getParameter(parameterId); // Просто делегирование
  }
}