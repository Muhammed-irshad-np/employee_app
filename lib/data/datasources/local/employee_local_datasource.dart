import 'package:sqflite/sqflite.dart';
import '../../models/employee.dart';
import 'database_helper.dart';

class EmployeeLocalDataSource {
  final DatabaseHelper dbHelper;

  EmployeeLocalDataSource({required this.dbHelper});

  Future<void> ensureDBInitialized() async {
    await dbHelper
        .database; // This ensures the database is initialized before queries.
  }

  Future<int> insertEmployee(Employee employee) async {
    await ensureDBInitialized(); // Ensure table exists
    final db = await dbHelper.database;
    return await db.insert('employees', employee.toMap());
  }

  Future<int> updateEmployee(Employee employee) async {
    await ensureDBInitialized();
    final db = await dbHelper.database;
    return await db.update(
      'employees',
      employee.toMap(),
      where: 'id = ?',
      whereArgs: [employee.id],
    );
  }

  Future<int> deleteEmployee(int id) async {
    await ensureDBInitialized();
    final db = await dbHelper.database;
    return await db.delete(
      'employees',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Employee>> getAllEmployees() async {
    await ensureDBInitialized();
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('employees');
    return List.generate(maps.length, (i) => Employee.fromMap(maps[i]));
  }

  Future<Employee?> getEmployee(int id) async {
    await ensureDBInitialized();
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'employees',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Employee.fromMap(maps.first);
    }
    return null;
  }
}
