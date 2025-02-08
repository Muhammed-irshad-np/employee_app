import 'package:employee_manager/data/models/employee.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../cubit/employee_cubit.dart';
import 'add_edit_employee_screen.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';

class EmployeeListScreen extends StatelessWidget {
  const EmployeeListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Employee List',
          style: theme.appBarTheme.titleTextStyle,
        ),
      ),
      body: BlocBuilder<EmployeeCubit, EmployeeState>(
        builder: (context, state) {
          if (state is EmployeeLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            );
          } else if (state is EmployeeLoaded) {
            if (state.employees.isEmpty) {
              return Center(
                child: Image.asset(
                  'assets/images/no_employee.png',
                  width: 200.w,
                  height: 200.h,
                ),
              );
            }

            final currentEmployees = state.employees
                .where((e) =>
                    e.endDate == null ||
                    DateUtils.dateOnly(e.endDate!)
                        .isAtSameMomentAs(DateUtils.dateOnly(DateTime.now())))
                .toList()
              ..sort((a, b) => b.startDate.compareTo(a.startDate));

            final previousEmployees = state.employees
                .where((e) =>
                    e.endDate != null &&
                    DateUtils.dateOnly(e.endDate!)
                        .isBefore(DateUtils.dateOnly(DateTime.now())))
                .toList()
              ..sort((a, b) => b.startDate.compareTo(a.startDate));

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: kIsWeb ? 76.h : 56.h,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Text(
                      'Current employees',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 18.sp,
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.only(left: 16.w),
                    children: [
                      ...currentEmployees.map((employee) => _buildEmployeeItem(
                            context,
                            employee,
                            theme,
                          )),
                    ],
                  ),
                ),
                Container(
                  height: kIsWeb ? 76.h : 56.h,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Text(
                      'Previous employees',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    children: [
                      ...previousEmployees.map((employee) => _buildEmployeeItem(
                            context,
                            employee,
                            theme,
                          )),
                    ],
                  ),
                ),
                Container(
                  height: 80.h,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: Padding(
                    padding: EdgeInsets.only(top: 12.h, left: 16.w),
                    child: Text(
                      "Swipe left to delete",
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(fontSize: 15.sp, color: Color(0xff949C9E)),
                    ),
                  ),
                )
              ],
            );
          } else if (state is EmployeeError) {
            return Center(
              child: Text(
                state.message,
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: theme.colorScheme.error, fontSize: 16.sp),
              ),
            );
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditEmployeeScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmployeeItem(
    BuildContext context,
    Employee employee,
    ThemeData theme,
  ) {
    return SwipeActionCell(
      key: ValueKey(employee.id),
      trailingActions: [
        SwipeAction(
          color: Colors.red,
          onTap: (CompletionHandler handler) async {
            // await _showDeleteConfirmation(
            //   context,
            //   employee.id!,
            //   employee.name,
            // );
            final cubit = context.read<EmployeeCubit>();
            cubit.deleteEmployee(employee.id!);
            final scaffoldMessenger = ScaffoldMessenger.of(context);

            // Show snackbar using the stored scaffoldMessenger
            scaffoldMessenger.showSnackBar(SnackBar(
              content: SizedBox(
                height: 40.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Employee data has been deleted',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 15.sp,
                        color: Colors.white,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        cubit.undoDelete();
                        scaffoldMessenger.hideCurrentSnackBar();
                      },
                      child: Text(
                        'Undo',
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF1DA1F2), fontSize: 15.sp),
                      ),
                    ),
                  ],
                ),
              ),
              backgroundColor: Colors.black87,
              behavior: SnackBarBehavior.fixed,
              duration: const Duration(seconds: 4),
            ));
            // await handler(false);
          },
          content: Padding(
            padding: EdgeInsets.all(8.w),
            child: ImageIcon(
              const AssetImage('assets/icons/delete.png'),
              size: 24.w,
              color: Colors.white,
            ),
          ),
        ),
      ],
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditEmployeeScreen(employee: employee),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          height: kIsWeb ? 112.h : 95.h,
          margin: EdgeInsets.only(bottom: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),
              Text(
                employee.name,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w500, fontSize: 16.sp),
              ),
              SizedBox(height: 6.h),
              Text(
                employee.role,
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: Colors.grey, fontSize: 16.sp),
              ),
              SizedBox(height: 6.h),
              if (employee.endDate != null)
                Text(
                  '${DateFormat('d MMM, yyyy').format(employee.startDate)} - ${DateFormat('d MMM, yyyy').format(employee.endDate!)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14.sp,
                    color: Colors.grey,
                  ),
                )
              else
                Text(
                  'From ${DateFormat('d MMM, yyyy').format(employee.startDate)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14.sp,
                    color: Colors.grey,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
