import 'package:employee_manager/core/theme/app_theme.dart';
import 'package:employee_manager/data/datasources/local/database_helper.dart';
import 'package:employee_manager/data/datasources/local/employee_local_datasource.dart';
import 'package:employee_manager/presentation/cubit/employee_cubit.dart';
import 'package:employee_manager/presentation/screens/employee_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:employee_manager/data/repositories/employee_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Use web-compatible database factory if running on Web
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final databaseHelper = DatabaseHelper.instance;
    final localDataSource = EmployeeLocalDataSource(dbHelper: databaseHelper);
    final repository = EmployeeRepository(localDataSource: localDataSource);

    return ScreenUtilInit(
        designSize: kIsWeb ? const Size(1440, 1024) : const Size(412, 919),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return BlocProvider(
            create: (context) =>
                EmployeeCubit(repository: repository)..loadEmployees(),
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Employee Management',
              theme: AppTheme.lightTheme,
              home: const EmployeeListScreen(),
            ),
          );
        });
  }
}
