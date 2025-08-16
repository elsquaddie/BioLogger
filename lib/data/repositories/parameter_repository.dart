import '../../models/parameter.dart';

abstract class ParameterRepository {
  Future<int> insertParameter(Parameter parameter);
  Future<Parameter?> getParameter(int id);
  Future<List<Parameter>> getAllParameters();
  Future<List<Parameter>> getEnabledParameters();
  Future<List<Parameter>> getPresetParameters();
  Future<List<Parameter>> getUserParameters();
  Future<int> updateParameter(Parameter parameter);
  Future<int> toggleParameterEnabled(int id, bool isEnabled);
  Future<int> updateParameterSortOrder(int id, int sortOrder);
  Future<void> updateParametersSortOrder(List<Parameter> parameters);
  Future<int> deleteParameter(int id);
  Future<bool> hasPresetParameters();
  Future<void> insertPresetParameters(List<Parameter> presets);
}