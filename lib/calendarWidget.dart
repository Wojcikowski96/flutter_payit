import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

// Example holidays
final Map<DateTime, List> _holidays = {
  DateTime(2020, 1, 1): ['New Year\'s Day'],
  DateTime(2020, 1, 6): ['Epiphany'],
  DateTime(2020, 2, 14): ['Valentine\'s Day'],
  DateTime(2020, 4, 21): ['Easter Sunday'],
  DateTime(2020, 4, 22): ['Easter Monday'],
};

class CalendarWidget extends StatefulWidget {
  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget>
    with TickerProviderStateMixin {
  Map<DateTime, List> _events;
  List _selectedEvents;
  CalendarController _calendarController;

  @override
  void initState() {
    super.initState();
    final _selectedDay = DateTime.now();

    _events = {
      DateTime(2021, 1, 22): ['Event A0', 'Event B0', 'Event C0'],
    };

    _selectedEvents = _events[_selectedDay] ?? [];
    _calendarController = CalendarController();
//    _animationController = AnimationController(
//      vsync: this,
//      duration: const Duration(milliseconds: 400),
//    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTableCalendarWithBuilders();
  }

  void _onDaySelected(DateTime day, List events, List holidays) {
    print('CALLBACK: _onDaySelected');
    setState(() {
      _selectedEvents = events;
    });
  }

  Widget _buildEventsMarker(DateTime date, List events, Color color) {
    print("Date");
    print(date);
    print("Events");
    print(events);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
          border: Border.all(
            color: color,
            width: 4,
          ),
          shape: BoxShape.rectangle,
          color: _calendarController.isSelected(date)
              ? Colors.transparent
              : _calendarController.isToday(date)
                  ? Colors.transparent
                  : Colors.transparent,
          borderRadius: BorderRadius.all(Radius.circular(20))),
      width: 55,
      height: 55,
      child: Stack(
        children: [
          Positioned(
            bottom: 1,
            right: 1,
            child: Text(
              '${events.length}',
              style: TextStyle().copyWith(
                color: Colors.red,
                fontSize: 16.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHolidaysMarker() {
    return Icon(
      Icons.add_box,
      size: 20.0,
      color: Colors.blueGrey[800],
    );
  }

  void _onVisibleDaysChanged(
      DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onVisibleDaysChanged');
  }

  void _onCalendarCreated(
      DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onCalendarCreated');
  }

  Widget _buildTableCalendarWithBuilders() {
    return TableCalendar(
      locale: 'pl_PL',
      calendarController: _calendarController,
      events: _events,
      holidays: _holidays,
      initialCalendarFormat: CalendarFormat.month,
      formatAnimation: FormatAnimation.slide,
      startingDayOfWeek: StartingDayOfWeek.sunday,
      availableGestures: AvailableGestures.all,
      availableCalendarFormats: const {
        CalendarFormat.month: '',
        CalendarFormat.week: '',
      },
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        weekendStyle: TextStyle().copyWith(color: Colors.blue[800]),
        holidayStyle: TextStyle().copyWith(color: Colors.blue[800]),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekendStyle: TextStyle().copyWith(color: Colors.blue[600]),
      ),
      headerStyle: HeaderStyle(
        centerHeaderTitle: true,
        formatButtonVisible: false,
      ),
      builders: CalendarBuilders(
        selectedDayBuilder: (context, date, _) {
          return Container(
            margin: const EdgeInsets.all(4.0),
            padding: const EdgeInsets.only(top: 5.0, left: 6.0),
            color: Colors.deepOrange[300],
            width: 80,
            height: 80,
            child: Text(
              '${date.day}',
              style: TextStyle().copyWith(fontSize: 16.0),
            ),
          );
        },
        todayDayBuilder: (context, date, _) {
          return Container(
            margin: const EdgeInsets.all(4.0),
            padding: const EdgeInsets.only(top: 5.0, left: 6.0),
            color: Colors.amber[400],
            width: 80,
            height: 80,
            child: Text(
              '${date.day}',
              style: TextStyle().copyWith(fontSize: 16.0),
            ),
          );
        },
        markersBuilder: (context, date, events, holidays) {
          final children = <Widget>[];

          if (events.isNotEmpty) {
            children.add(
              Positioned(
                child: _buildEventsMarker(date, events, Colors.red),
              ),
            );
          }

          if (holidays.isNotEmpty) {
            children.add(
              Positioned(
                child: _buildHolidaysMarker(),
              ),
            );
          }
          return children;
        },
      ),
      onDaySelected: (date, events, holidays) {
        _onDaySelected(date, events, holidays);
        //_animationController.forward(from: 0.0);
      },
      onVisibleDaysChanged: _onVisibleDaysChanged,
      onCalendarCreated: _onCalendarCreated,
    );
  }
}
