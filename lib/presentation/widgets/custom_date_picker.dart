import 'package:employee_manager/core/constants/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomDatePicker extends StatefulWidget {
  final DateTime? selectedDate;
  final Function(DateTime?) onDateSelected;
  final String label;
  final String textLabel;
  final bool isfirstDate;

  CustomDatePicker({
    Key? key,
    this.selectedDate,
    required this.onDateSelected,
    required this.label,
    required this.textLabel,
    required this.isfirstDate,
  }) : super(key: key);

  @override
  _CustomDatePickerState createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  DateTime? _selectedDate;
  late String _label;

  DateTime? prevDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    prevDate = widget.selectedDate;
    _label = widget.label;
  }

  @override
  void didUpdateWidget(covariant CustomDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      setState(() {
        _selectedDate = widget.selectedDate;
        _label = widget.selectedDate != null
            ? (_isSameDay(widget.selectedDate!, DateTime.now())
                ? 'Today'
                : DateFormat('d MMM yyyy').format(widget.selectedDate!))
            : widget.label;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime currentDate = DateTime.now();
    final DateTime? picked = await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 16.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: _CalendarView(
            prevdate: prevDate ?? currentDate,
            isfirstDate: widget.isfirstDate,
            selectedDate: _selectedDate ?? currentDate,
            onDateSelected: (date) => Navigator.pop(context, date),
            label: _label,
            textLabel: widget.textLabel,
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _label = _isSameDay(picked, DateTime.now())
            ? 'Today'
            : DateFormat('d MMM yyyy').format(picked);
      });
      widget.onDateSelected(picked);
    } else {
      setState(() {
        _selectedDate = null;
        _label = 'No date';
        widget.onDateSelected(null);
      });
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.inputDecorationTheme.enabledBorder?.borderSide.color ??
                Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(4.r),
          color: theme.inputDecorationTheme.fillColor,
        ),
        child: Row(
          children: [
            ImageIcon(
              const AssetImage('assets/icons/date_icon.png'),
              size: 24.h,
              color: Colors.blue[600],
            ),
            SizedBox(width: 9.w),
            Text(
              _selectedDate != null
                  ? (_isSameDay(_selectedDate!, DateTime.now())
                      ? 'Today'
                      : DateFormat('d MMM yyyy').format(_selectedDate!))
                  : _label,
              style: (_selectedDate == null || _label == 'No date')
                  ? Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xff949C9E),
                      )
                  : Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarView extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime?) onDateSelected;
  final String label;
  final String textLabel;
  final bool isfirstDate;
  final DateTime prevdate;

  const _CalendarView(
      {required this.selectedDate,
      required this.onDateSelected,
      required this.label,
      required this.textLabel,
      required this.isfirstDate,
      required this.prevdate});

  @override
  State<_CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<_CalendarView> {
  late DateTime _currentMonth;
  late DateTime _selectedDate;
  late DateTime _prevdate;
  bool _isNoDateSelected = false;
  String _selectedQuickOption = '';

  @override
  void initState() {
    super.initState();
    // Use the provided selectedDate if available, otherwise default to DateTime.now()
    _selectedDate = widget.selectedDate ?? DateTime.now();
    _currentMonth = widget.selectedDate ?? DateTime.now();
    _prevdate = widget.selectedDate ?? DateTime.now();

    // Set _isNoDateSelected based solely on whether a date was provided
    _isNoDateSelected = widget.selectedDate == null;
    _setInitialQuickOption();
  }

  void _setInitialQuickOption() {
    final today = DateTime.now();
    if (widget.selectedDate == null) {
      _selectedQuickOption = 'No date';
    } else {
      if (_isSameDay(_selectedDate, today)) {
        _selectedQuickOption = 'Today';
      } else if (_isSameDay(_selectedDate, _getNextWeekday(DateTime.monday))) {
        _selectedQuickOption = 'Next Monday';
      } else if (_isSameDay(_selectedDate, _getNextWeekday(DateTime.tuesday))) {
        _selectedQuickOption = 'Next Tuesday';
      } else if (_isSameDay(
          _selectedDate, today.add(const Duration(days: 7)))) {
        _selectedQuickOption = 'After 1 week';
      } else {
        _selectedQuickOption = '';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: kIsWeb
            ? MediaQuery.of(context).size.height * 0.9
            : MediaQuery.of(context).size.height,
        maxWidth: kIsWeb
            ? MediaQuery.of(context).size.width * 0.8
            : MediaQuery.of(context).size.width,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildQuickSelectButtons(),
              SizedBox(height: 24.h),
              _buildMonthHeader(),
              SizedBox(height: 24.h),
              _buildCalendarGrid(),
              SizedBox(height: 16.h),
              Divider(
                color: Color(0xFFF2F2F2),
                thickness: 1.h,
              ),
              SizedBox(
                height: 16.h,
              ),
              _buildBottomSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickSelectButtons() {
    if (widget.textLabel == 'No date') {
      return Column(
        children: [
          Row(
            children: [
              _QuickDateButton(
                label: 'No date',
                onTap: () {
                  setState(() {
                    _isNoDateSelected = true;
                    _selectedQuickOption = 'No date';
                  });
                },
                color: _isNoDateSelected
                    ? const Color(0xFF1DA1F2)
                    : const Color(0xFFEDF8FF),
                textColor:
                    _isNoDateSelected ? Colors.white : AppColors.primaryBlue,
              ),
              SizedBox(width: 16.w),
              _QuickDateButton(
                label: 'Today',
                onTap: () {
                  setState(() {
                    _selectedDate = DateTime.now();
                    _isNoDateSelected = false;
                    _selectedQuickOption = 'Today';
                  });
                },
                color: (!_isNoDateSelected && _selectedQuickOption == 'Today')
                    ? const Color(0xFF1DA1F2)
                    : const Color(0xFFEDF8FF),
                textColor:
                    (!_isNoDateSelected && _selectedQuickOption == 'Today')
                        ? Colors.white
                        : AppColors.primaryBlue,
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      children: [
        Row(
          children: [
            _QuickDateButton(
              label: 'Today',
              onTap: () {
                _selectDate(DateTime.now());
                setState(() {
                  _selectedQuickOption = 'Today';
                });
              },
              color: _selectedQuickOption == 'Today'
                  ? const Color(0xFF1DA1F2)
                  : const Color(0xFFEDF8FF),
              textColor: _selectedQuickOption == 'Today'
                  ? Colors.white
                  : AppColors.primaryBlue,
            ),
            SizedBox(width: 16.w),
            _QuickDateButton(
              label: 'Next Monday',
              onTap: () {
                _selectDate(_getNextWeekday(DateTime.monday));
                setState(() {
                  _selectedQuickOption = 'Next Monday';
                });
              },
              color: _selectedQuickOption == 'Next Monday'
                  ? const Color(0xFF1DA1F2)
                  : const Color(0xFFEDF8FF),
              textColor: _selectedQuickOption == 'Next Monday'
                  ? Colors.white
                  : AppColors.primaryBlue,
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            _QuickDateButton(
              label: 'Next Tuesday',
              onTap: () {
                _selectDate(_getNextWeekday(DateTime.tuesday));
                setState(() {
                  _selectedQuickOption = 'Next Tuesday';
                });
              },
              color: _selectedQuickOption == 'Next Tuesday'
                  ? const Color(0xFF1DA1F2)
                  : const Color(0xFFEDF8FF),
              textColor: _selectedQuickOption == 'Next Tuesday'
                  ? Colors.white
                  : AppColors.primaryBlue,
            ),
            SizedBox(width: 16.w),
            _QuickDateButton(
              label: 'After 1 week',
              onTap: () {
                _selectDate(DateTime.now().add(const Duration(days: 7)));
                setState(() {
                  _selectedQuickOption = 'After 1 week';
                });
              },
              color: _selectedQuickOption == 'After 1 week'
                  ? const Color(0xFF1DA1F2)
                  : const Color(0xFFEDF8FF),
              textColor: _selectedQuickOption == 'After 1 week'
                  ? Colors.white
                  : AppColors.primaryBlue,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMonthHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(
            size: 30.w,
            Icons.arrow_left_rounded,
            color: const Color(0xFF949C9E),
          ),
          onPressed: _previousMonth,
        ),
        Text(
          DateFormat('MMMM yyyy').format(_currentMonth),
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        IconButton(
          icon: Icon(
            size: 30.w,
            Icons.arrow_right_rounded,
            color: Color(0xFF949C9E),
          ),
          onPressed: _nextMonth,
        ),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    return Column(
      children: [
        _buildWeekdayHeader(),
        SizedBox(height: 8.h),
        _buildDaysGrid(),
      ],
    );
  }

  Widget _buildWeekdayHeader() {
    final weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays
          .map((day) => SizedBox(
                width: 40.w,
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp,
                    color: Colors.black54,
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildDaysGrid() {
    final daysInMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final firstDayOfMonth =
        DateTime(_currentMonth.year, _currentMonth.month, 1);
    final firstWeekday = firstDayOfMonth.weekday;
    final leadingDays = firstWeekday % 7;
    final today = DateTime.now();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: leadingDays + daysInMonth,
      itemBuilder: (context, index) {
        if (index < leadingDays) {
          return const SizedBox();
        }

        final day = index - leadingDays + 1;
        final date = DateTime(_currentMonth.year, _currentMonth.month, day);
        final isSelected =
            !_isNoDateSelected && _isSameDay(date, _selectedDate);
        final isToday = _isSameDay(date, today);

        final isDisabled = widget.label == 'No date' && date.isAfter(today);

        return GestureDetector(
          onTap: isDisabled ? null : () => _selectDate(date),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? Theme.of(context).colorScheme.primary : null,
              border: isToday && !isSelected
                  ? Border.all(
                      color: Theme.of(context).colorScheme.primary, width: 1)
                  : null,
            ),
            child: Center(
              child: Text(
                day.toString(),
                style: TextStyle(
                  color: isDisabled
                      ? Colors.grey
                      : isSelected
                          ? Colors.white
                          : isToday && !isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.black87,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            ImageIcon(
              const AssetImage('assets/icons/date_icon.png'),
              size: 24.w,
              color: Colors.blue[600],
            ),
            SizedBox(width: 8.w),
            Text(
              _isNoDateSelected
                  ? 'No date'
                  : DateFormat('d MMM yyyy').format(_selectedDate!),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                if (widget.isfirstDate == false &&
                    _selectedQuickOption == 'No date') {
                  widget.onDateSelected(null);
                } else {
                  widget.onDateSelected(_prevdate);
                }
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.r)),
                backgroundColor: Color(0xFFEDF8FF),
                foregroundColor: Color(0xFF1DA1F2),
              ),
              child: const Text('Cancel'),
            ),
            SizedBox(width: 16.w),
            ElevatedButton(
              onPressed: () {
                if (_selectedQuickOption == 'No date' && _isNoDateSelected) {
                  widget.onDateSelected(null);
                } else {
                  widget.onDateSelected(_selectedDate);
                }
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.r)),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ],
    );
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month - 1,
        _currentMonth.day,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month + 1,
        _currentMonth.day,
      );
    });
  }

  DateTime _getNextWeekday(int weekday) {
    DateTime date = DateTime.now();
    while (date.weekday != weekday) {
      date = date.add(const Duration(days: 1));
    }
    return date;
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
      _currentMonth = date;
      _isNoDateSelected = false;
      if (_isSameDay(date, DateTime.now())) {
        _selectedQuickOption = 'Today';
      } else if (_isSameDay(date, _getNextWeekday(DateTime.monday))) {
        _selectedQuickOption = 'Next Monday';
      } else if (_isSameDay(date, _getNextWeekday(DateTime.tuesday))) {
        _selectedQuickOption = 'Next Tuesday';
      } else if (_isSameDay(
          date, DateTime.now().add(const Duration(days: 7)))) {
        _selectedQuickOption = 'After 1 week';
      } else {
        _selectedQuickOption = '';
      }
    });
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _QuickDateButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;
  final Color textColor;

  const _QuickDateButton(
      {required this.label,
      required this.onTap,
      required this.color,
      required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.symmetric(vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }
}
