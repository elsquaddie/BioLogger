import '../../models/parameter.dart';
import '../../data/repositories/parameter_repository.dart';
import '../../data/repositories/parameter_repository_impl.dart';

class CreateParameterUseCase {
  final ParameterRepository _parameterRepository = ParameterRepositoryImpl(); // Репозиторий

  Future<int> execute(Parameter parameter) async {
    // Здесь может быть бизнес-логика, валидация перед созданием параметра
    // Например, проверка, что имя параметра не пустое, тип данных валидный и т.д.
    if (parameter.name.isEmpty) {
      throw Exception("Parameter name cannot be empty"); // Пример валидации
    }
    return await _parameterRepository.insertParameter(parameter); // Вызываем репозиторий для сохранения
  }
}