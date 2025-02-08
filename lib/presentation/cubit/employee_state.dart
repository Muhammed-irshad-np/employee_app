part of 'employee_cubit.dart';

@immutable
sealed class EmployeeState {}

final class EmployeeInitial extends EmployeeState {}

final class EmployeeLoading extends EmployeeState {}

final class EmployeeLoaded extends EmployeeState {
  final List<Employee> employees;

  EmployeeLoaded({required this.employees});

  EmployeeLoaded copyWith({
    List<Employee>? employees,
  }) {
    return EmployeeLoaded(
      employees: employees ?? this.employees,
    );
  }
}

final class EmployeeError extends EmployeeState {
  final String message;

  EmployeeError({required this.message});

  EmployeeError copyWith({
    String? message,
  }) {
    return EmployeeError(
      message: message ?? this.message,
    );
  }
}
