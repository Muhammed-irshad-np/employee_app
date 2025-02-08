import 'package:employee_manager/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/employee.dart';
import '../cubit/employee_cubit.dart';
import '../widgets/custom_date_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddEditEmployeeScreen extends StatefulWidget {
  final Employee? employee;

  const AddEditEmployeeScreen({Key? key, this.employee}) : super(key: key);

  @override
  State<AddEditEmployeeScreen> createState() => _AddEditEmployeeScreenState();
}

class _AddEditEmployeeScreenState extends State<AddEditEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  String? _selectedRole;
  DateTime? _startDate;
  DateTime? _endDate;

  final List<String> _roles = [
    'Product Designer',
    'Flutter Developer',
    'QA Tester',
    'Product Owner'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.employee?.name);
    _selectedRole = widget.employee?.role;
    _startDate = widget.employee?.startDate ?? DateTime.now();
    _endDate = widget.employee?.endDate;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.read<EmployeeCubit>();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          widget.employee == null
              ? 'Add Employee Details'
              : 'Edit Employee Details',
          style: theme.appBarTheme.titleTextStyle,
        ),
        actions: [
          if (widget.employee != null)
            IconButton(
              onPressed: () {
                if (widget.employee?.id != null) {
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Employee data has been deleted',
                            style: theme.textTheme.bodyMedium?.copyWith(
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
                                color: const Color(0xFF1DA1F2),
                              ),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.black87,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                  cubit.deleteEmployee(widget.employee!.id!);
                  Navigator.pop(context);
                }
              },
              icon: ImageIcon(
                const AssetImage('assets/icons/delete.png'),
                size: 24.w,
                color: Colors.white,
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding:
              EdgeInsets.only(top: 24.h, bottom: 16.h, left: 16.h, right: 16.h),
          child: Column(
            children: [
              // SizedBox(height: 24.h),
              TextFormField(
                controller: _nameController,
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  labelText: 'Employee name',
                  labelStyle: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.grey,
                  ),
                  prefixIcon: ImageIcon(
                    const AssetImage('assets/icons/person_icon.png'),
                    size: 24.w,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter employee name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 23.h),
              InkWell(
                onTap: () => _showRoleBottomSheet(context),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      ImageIcon(
                        const AssetImage('assets/icons/role_icon.png'),
                        size: 24.w,
                        color: Colors.blue[600],
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          _selectedRole ?? 'Select role',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: _selectedRole == null
                                ? AppColors.grey
                                : AppColors.black,
                          ),
                        ),
                      ),
                      ImageIcon(
                        const AssetImage('assets/icons/downArrow_icon.png'),
                        size: 24.w,
                        color: Colors.blue[600],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 23.h),
              Row(
                children: [
                  Expanded(
                    child: CustomDatePicker(
                      isfirstDate: true,
                      label: 'Today',
                      selectedDate: _startDate,
                      textLabel: 'Today',
                      onDateSelected: (date) {
                        setState(() {
                          _startDate = date;
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 16.h, right: 16.h),
                    child: ImageIcon(
                      const AssetImage('assets/icons/rightArrow_icon.png'),
                      color: Colors.blue[600],
                      size: 20.w,
                    ),
                  ),
                  Expanded(
                    child: CustomDatePicker(
                      isfirstDate: false,
                      label: 'No date',
                      selectedDate: _endDate,
                      textLabel: 'No date',
                      onDateSelected: (date) {
                        setState(() {
                          _endDate = date;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEDF8FF),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              ElevatedButton(
                onPressed: _saveEmployee,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(
                  'Save',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.elevatedButtonTheme.style?.foregroundColor
                        ?.resolve({}),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveEmployee() {
    if (_formKey.currentState!.validate() &&
        _startDate != null &&
        _selectedRole != null) {
      final employee = Employee(
        id: widget.employee?.id,
        name: _nameController.text,
        role: _selectedRole!,
        startDate: _startDate!,
        endDate: _endDate,
      );

      if (widget.employee == null) {
        context.read<EmployeeCubit>().addEmployee(employee);
      } else {
        context.read<EmployeeCubit>().updateEmployee(employee);
      }

      Navigator.pop(context);
    }
  }

  void _showRoleBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView.separated(
          shrinkWrap: true,
          itemCount: _roles.length,
          separatorBuilder: (context, index) => Divider(
            height: 1.h,
            color: Colors.blueGrey.shade200,
            thickness: 0.4.h,
          ),
          itemBuilder: (context, index) {
            final role = _roles[index];
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedRole = role;
                });
                Navigator.pop(context);
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      role,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
