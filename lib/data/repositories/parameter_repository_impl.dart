import '../local_database/parameter_dao.dart';
import '../../models/parameter.dart';
import 'parameter_repository.dart';

class ParameterRepositoryImpl implements ParameterRepository {
  final ParameterDao _parameterDao = ParameterDao(); // Создаем экземпляр ParameterDao

  @override
  Future<int> insertParameter(Parameter parameter) async {
    return await _parameterDao.insertParameter(parameter); // Просто делегируем вызов в DAO
  }

  @override
  Future<Parameter?> getParameter(int id) async {
    return await _parameterDao.getParameter(id); // Делегируем в DAO
  }

  @override
  Future<List<Parameter>> getAllParameters() async {
    return await _parameterDao.getAllParameters(); // Делегируем в DAO
  }

  @override
  Future<int> updateParameter(Parameter parameter) async {
    return await _parameterDao.updateParameter(parameter); // Делегируем в DAO
  }

  @override
  Future<int> deleteParameter(int id) async {
    return await _parameterDao.deleteParameter(id); // Делегируем в DAO
  }
}