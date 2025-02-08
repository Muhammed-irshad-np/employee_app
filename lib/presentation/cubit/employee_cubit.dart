import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import '../../data/models/employee.dart';
import '../../data/repositories/employee_repository.dart';

part 'employee_state.dart';

class EmployeeCubit extends Cubit<EmployeeState> {
  final EmployeeRepository repository;
  Employee? _lastDeletedEmployee;

  EmployeeCubit({required this.repository}) : super(EmployeeInitial());

  Future<void> loadEmployees() async {
    try {
      emit(EmployeeLoading());
      final employees = await repository.getAllEmployees();
      emit(EmployeeLoaded(employees: employees));
    } catch (e) {
      emit(EmployeeError(message: e.toString()));
    }
  }

  Future<void> addEmployee(Employee employee) async {
    try {
      emit(EmployeeLoading());
      await repository.addEmployee(employee);
      await loadEmployees();
    } catch (e) {
      emit(EmployeeError(message: e.toString()));
    }
  }

  Future<void> updateEmployee(Employee employee) async {
    try {
      emit(EmployeeLoading());
      await repository.updateEmployee(employee);
      await loadEmployees();
    } catch (e) {
      emit(EmployeeError(message: e.toString()));
    }
  }

  Future<void> deleteEmployee(int id) async {
    try {
      _lastDeletedEmployee = await repository.getEmployee(id);
      emit(EmployeeLoading());
      await repository.deleteEmployee(id);
      await loadEmployees();
    } catch (e) {
      emit(EmployeeError(message: e.toString()));
    }
  }

  Future<void> undoDelete() async {
    if (_lastDeletedEmployee != null) {
      try {
        emit(EmployeeLoading());
        await repository.addEmployee(_lastDeletedEmployee!);
        _lastDeletedEmployee = null;
        await loadEmployees();
      } catch (e) {
        emit(EmployeeError(message: e.toString()));
      }
    }
  }
}
