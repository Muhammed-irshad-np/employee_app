import '../datasources/local/employee_local_datasource.dart';
import '../models/employee.dart';

class EmployeeRepository {
  final EmployeeLocalDataSource localDataSource;

  EmployeeRepository({required this.localDataSource});

  Future<List<Employee>> getAllEmployees() async {
    return await localDataSource.getAllEmployees();
  }

  Future<int> addEmployee(Employee employee) async {
    return await localDataSource.insertEmployee(employee);
  }

  Future<int> updateEmployee(Employee employee) async {
    return await localDataSource.updateEmployee(employee);
  }

  Future<int> deleteEmployee(int id) async {
    return await localDataSource.deleteEmployee(id);
  }

  Future<Employee?> getEmployee(int id) async {
    return await localDataSource.getEmployee(id);
  }
}
