import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:hearable_device_sdk_sample/calendar.dart';
import 'package:hearable_device_sdk_sample/hearable_service_view.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';

//import 'package:hearable_device_sdk_sample/size_config.dart';
//import 'package:hearable_device_sdk_sample/widget_config.dart';
import 'package:hearable_device_sdk_sample/widgets.dart';
import 'package:hearable_device_sdk_sample/alert.dart';
import 'package:hearable_device_sdk_sample/nine_axis_sensor.dart';
import 'package:hearable_device_sdk_sample/temperature.dart';
import 'package:hearable_device_sdk_sample/heart_rate.dart';
import 'package:hearable_device_sdk_sample/ppg.dart';
import 'package:hearable_device_sdk_sample/eaa.dart';
import 'package:hearable_device_sdk_sample/battery.dart';
import 'package:hearable_device_sdk_sample/config.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:hearable_device_sdk_sample_plugin/hearable_device_sdk_sample_plugin.dart';
import 'dart:math' as math;

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List> _eventsList = {};
  final _events = LinkedHashMap();
  int _selectedIndex = 1;

  int getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HearableServiceView()),
        );
      } else if (index == 1) {
        // Calendar画面に遷移
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    //サンプルのイベントリスト
    _eventsList = {
      DateTime.now().subtract(Duration(days: 2)): ['1 セット ✓', '2 セット ✓'],
      DateTime.now(): ['1 セット ✓', '2 セット ✓', '3 セット ✓'],
      DateTime.now().subtract(Duration(days: 1)): ['1 セット ✓'],
      DateTime.now().subtract(Duration(days: 3)): Set.from(['1 セット ✓', '2 セット ✓', '3 セット ✓']).toList(),
      DateTime.now().subtract(Duration(days: 5)): ['1 セット ✓', '2 セット ✓'],
      DateTime.now().subtract(Duration(days: 7)): ['1 セット ✓','2 セット ✓','3 セット ✓'],
      DateTime.now().subtract(Duration(days: 11)): ['1 セット ✓', '2 セット ✓'],
      DateTime.now().subtract(Duration(days: 17)): ['1 セット ✓'],
      DateTime.now().subtract(Duration(days: 22)): ['1 セット ✓', '2 セット ✓'],
      DateTime.now().subtract(Duration(days: 22)): ['1 セット ✓', '2 セット ✓'],
      DateTime.now().subtract(Duration(days: 26)): ['1 セット ✓','2 セット ✓','3 セット ✓'],
    };
  }

  @override
  Widget build(BuildContext context) {

    final _events = LinkedHashMap<DateTime, List>(
      equals: isSameDay,
      hashCode: getHashCode,
    )..addAll(_eventsList);

    List _getEventForDay(DateTime day) {
      return _events[day] ?? [];
    }   

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar確認', style: TextStyle(fontSize: 16)),
        centerTitle: true,
        backgroundColor: Color.fromARGB(47, 10, 66, 187),
      ),
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/background_image_2.jpg'),
                  //fit: BoxFit.cover,
                  fit: BoxFit.fitHeight),
            ),
          ),
          Container(
            // margin: EdgeInsets.symmetric(vertical: 150),
            child: TableCalendar(
                locale: 'ja_JP',
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                eventLoader: _getEventForDay, 
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                ),
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    _getEventForDay(selectedDay); 
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
              ),
          ),
              ListView(
                shrinkWrap: true,
                children: _getEventForDay(_selectedDay!)
                    .map((event) => ListTile(
                          title: Text(event.toString())
                        ))
                    .toList(),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  child: Container(
                    width: 320,
                    height: 100,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '現在のユーザーレベル',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            ' 21 Lv.',
                            style: TextStyle(
                              fontSize: 30,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
       items: const [
         BottomNavigationBarItem(
           icon: Icon(Icons.home),
           label: 'Home',
         ),
         BottomNavigationBarItem(
           icon: Icon(Icons.calendar_today),
           label: 'Calendar',
         ),
       ],
       currentIndex: _selectedIndex,
       selectedItemColor: Color.fromARGB(255, 26, 154, 228),
       onTap: _onItemTapped,
     ),
    );
  }
}
