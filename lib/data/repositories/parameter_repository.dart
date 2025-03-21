import '../../models/parameter.dart';

abstract class ParameterRepository {
  Future<int> insertParameter(Parameter parameter);
  Future<Parameter?> getParameter(int id);
  Future<List<Parameter>> getAllParameters();
  Future<int> updateParameter(Parameter parameter);
  Future<int> deleteParameter(int id);
}