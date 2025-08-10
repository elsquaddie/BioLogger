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
  Future<List<Parameter>> getEnabledParameters() async {
    return await _parameterDao.getEnabledParameters();
  }

  @override
  Future<List<Parameter>> getPresetParameters() async {
    return await _parameterDao.getPresetParameters();
  }

  @override
  Future<List<Parameter>> getUserParameters() async {
    return await _parameterDao.getUserParameters();
  }

  @override
  Future<int> updateParameter(Parameter parameter) async {
    return await _parameterDao.updateParameter(parameter); // Делегируем в DAO
  }

  @override
  Future<int> toggleParameterEnabled(int id, bool isEnabled) async {
    return await _parameterDao.toggleParameterEnabled(id, isEnabled);
  }

  @override
  Future<int> updateParameterSortOrder(int id, int sortOrder) async {
    return await _parameterDao.updateParameterSortOrder(id, sortOrder);
  }

  @override
  Future<int> deleteParameter(int id) async {
    return await _parameterDao.deleteParameter(id); // Делегируем в DAO
  }

  @override
  Future<bool> hasPresetParameters() async {
    return await _parameterDao.hasPresetParameters();
  }

  @override
  Future<void> insertPresetParameters(List<Parameter> presets) async {
    return await _parameterDao.insertPresetParameters(presets);
  }
}