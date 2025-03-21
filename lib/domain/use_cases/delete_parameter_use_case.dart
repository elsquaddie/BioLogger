import '../../data/repositories/parameter_repository.dart';
import '../../data/repositories/parameter_repository_impl.dart';

class DeleteParameterUseCase {
  final ParameterRepository _parameterRepository = ParameterRepositoryImpl();

  Future<int> execute(int parameterId) async {
    // Здесь может быть бизнес-логика перед удалением, например, проверка, что параметр не используется в ежедневных записях
    return await _parameterRepository.deleteParameter(parameterId);
  }
}