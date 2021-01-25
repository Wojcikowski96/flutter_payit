import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'homePage.dart';
// Example holidays
final Map<DateTime, List> _holidays = {
  DateTime(2020, 1, 1): ['Nowy Rok'],
  DateTime(2020, 1, 6): ['Trzech Króli'],
  DateTime(2020, 4, 21): ['Wielkanoc'],
  DateTime(2020, 4, 22): ['Poniedziałek wielkanocny'],
  DateTime(2021, 1, 1): ['Nowy Rok'],
  DateTime(2021, 1, 6): ['Trzech Króli'],
};

class CalendarWidget extends StatefulWidget {
  final Map<DateTime, List> events;
  final Function(DateTime date, List events) notifyParent;

  CalendarWidget({Key key, @required this.events, this.notifyParent}) : super(key: key);
  
  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget>
    with TickerProviderStateMixin {

  List _selectedEvents;
  DateTime _selectedDay = DateTime.now();
  CalendarController _calendarController;

  @override
  void initState() {
    super.initState();

    _selectedEvents = widget.events[_selectedDay] ?? [];
    _calendarController = CalendarController();

  }

  @override
  Widget build(BuildContext context) {
    return _buildTableCalendarWithBuilders();
  }

  void _onDaySelected(DateTime day, List events, List holidays) {
    _selectedDay=day;
    widget.notifyParent(day,events);
    setState(() {
      _selectedEvents = events;
          });
  }

  Widget _buildEventsMarker(DateTime date, List events) {

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
          border: Border.all(
            color: colorFromName(events[0].split("|")[4]),
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
            right: 2,
            child: Text(
              '${events.length}',
              style: TextStyle(fontWeight: FontWeight.bold).copyWith(
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
    if(_selectedDay==null)
    widget.notifyParent(first,[]);
  }

  void _onCalendarCreated(
      DateTime first, DateTime last, CalendarFormat format) {
  }

  Widget _buildTableCalendarWithBuilders() {
    return TableCalendar(
      locale: 'pl_PL',
      calendarController: _calendarController,
      events: widget.events,
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
            decoration: BoxDecoration(
                color: Colors.grey,
              borderRadius: BorderRadius.all(Radius.circular(15))
            ),
            margin: const EdgeInsets.all(4.0),
            padding: const EdgeInsets.only(top: 5.0, left: 6.0),

            width: 82,
            height: 82,
            child: Text(
              '${date.day}',
              style: TextStyle().copyWith(fontSize: 16.0),
            ),
          );
        },
        todayDayBuilder: (context, date, _) {
          return Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.blue,
                width: 4,
              ),
              color: Colors.blue,
                borderRadius: BorderRadius.all(Radius.circular(15))

            ),
            margin: const EdgeInsets.all(4.0),
            padding: const EdgeInsets.only(top: 5.0, left: 6.0),
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
                child: _buildEventsMarker(date, events),
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
      onHeaderTapped: _onHeaderTapped,
    );
  }

Color colorFromName(String name) {
  if(name == "MaterialColor(primary value: Color(0xfff44336))") {
    return Colors.red;
  }else if(name == "MaterialColor(primary value: Color(0xffffc107))"){
    return Colors.amber;
  }else{
    return Colors.green;
  }
}

  void _onHeaderTapped(DateTime focusedDay) {
  }
}
