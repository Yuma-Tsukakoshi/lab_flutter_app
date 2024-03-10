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

class Result extends StatelessWidget {
  Result(this.setCount);
  final int setCount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //leadingWidth: SizeConfig.blockSizeHorizontal * 20,
        //leading: Widgets.barBackButton(context),
        title: const Text('クエスト達成率確認', style: TextStyle(fontSize: 16)),
        centerTitle: true,
        backgroundColor: Color.fromARGB(46, 187, 110, 10),
        //iconTheme: const IconThemeData(color: Colors.blue),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/background_image_2.jpg'),
                  //fit: BoxFit.cover,
                  fit: BoxFit.fitHeight),
            ),
          ),
          Center(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 150),
                  child: Column(
                    children: [
                      Text(
                        '今日のクエスト達成率',
                        style: TextStyle(
                          fontSize: 25,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 50),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Card(
                            child: Container(
                              width: 320,
                              height: 120,
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '1セット',
                                      style: TextStyle(
                                        fontSize: 40,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 50,
                                    ),
                                    Icon(
                                      Icons.task_alt,
                                      color: setCount >= 3 ? Colors.black : Colors.blue,
                                      size: 50,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Card(
                            child: Container(
                              width: 320,
                              height: 120,
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '2セット',
                                      style: TextStyle(
                                        fontSize: 40,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 50,
                                    ),
                                    Icon(
                                      Icons.task_alt,
                                      color: setCount >= 2 ? Colors.black : Colors.blue,
                                      size: 50,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Card(
                            child: Container(
                              width: 320,
                              height: 120,
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '3セット',
                                      style: TextStyle(
                                        fontSize: 40,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 50,
                                    ),
                                    Icon(
                                      Icons.task_alt,
                                      color:  setCount >= 1 ? Colors.black : Colors.blue,
                                      size: 50,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
    //   bottomNavigationBar: BottomNavigationBar(
    //    items: const [
    //      BottomNavigationBarItem(
    //        icon: Icon(Icons.home),
    //        label: 'Home',
    //      ),
    //      BottomNavigationBarItem(
    //        icon: Icon(Icons.calendar_today),
    //        label: 'Calendar',
    //      ),
    //    ],
    //    currentIndex: _selectedIndex,
    //    selectedItemColor: Color.fromARGB(255, 26, 154, 228),
    //    onTap: _onItemTapped,
    //  ),
//     );
// }

// class _HearableServiceView extends StatefulWidget {
//   @override
//   State<_HearableServiceView> createState() => _HearableServiceViewState();
// }

// class _HearableServiceViewState extends State<_HearableServiceView> {
//   int _selectedIndex = 0;

 
//   // void _onItemTapped(int index) {
//   // setState(() {
//   //   _selectedIndex = index;
//   //   if (index == 0) {
//   //     Navigator.push(
//   //       context,
//   //       MaterialPageRoute(builder: (context) => HearableServiceView()),
//   //     );
//   //   } else if (index == 1) {
//   //     Navigator.push(
//   //       context,
//   //       MaterialPageRoute(builder: (context) => Calendar()),
//   //     );
//   //   }
//   // });
// }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         //leadingWidth: SizeConfig.blockSizeHorizontal * 20,
//         //leading: Widgets.barBackButton(context),
//         title: const Text('クエスト達成率確認', style: TextStyle(fontSize: 16)),
//         centerTitle: true,
//         backgroundColor: Color.fromARGB(46, 187, 110, 10),
//         //iconTheme: const IconThemeData(color: Colors.blue),
//       ),
//       body: Stack(
//         children: [
//           Container(
//             decoration: const BoxDecoration(
//               image: DecorationImage(
//                   image: AssetImage('assets/background_image_2.jpg'),
//                   //fit: BoxFit.cover,
//                   fit: BoxFit.fitHeight),
//             ),
//           ),
//           Center(
//             child: Column(
//               children: [
//                 Container(
//                   margin: const EdgeInsets.only(top: 150),
//                   child: Column(
//                     children: [
//                       Text(
//                         '今日のクエスト達成率',
//                         style: TextStyle(
//                           fontSize: 25,
//                           color: Colors.black,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 50),
//                       Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Card(
//                             child: Container(
//                               width: 320,
//                               height: 120,
//                               child: Center(
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Text(
//                                       '1セット',
//                                       style: TextStyle(
//                                         fontSize: 40,
//                                         color: Colors.black,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     SizedBox(
//                                       width: 50,
//                                     ),
//                                     Icon(
//                                       Icons.task_alt,
//                                       color: setCount >= 3 ? Colors.black : Colors.blue,
//                                       size: 50,
//                                     )
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                           Card(
//                             child: Container(
//                               width: 320,
//                               height: 120,
//                               child: Center(
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Text(
//                                       '2セット',
//                                       style: TextStyle(
//                                         fontSize: 40,
//                                         color: Colors.black,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     SizedBox(
//                                       width: 50,
//                                     ),
//                                     Icon(
//                                       Icons.task_alt,
//                                       color: setCount >= 2 ? Colors.black : Colors.blue,
//                                       size: 50,
//                                     )
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                           Card(
//                             child: Container(
//                               width: 320,
//                               height: 120,
//                               child: Center(
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Text(
//                                       '3セット',
//                                       style: TextStyle(
//                                         fontSize: 40,
//                                         color: Colors.black,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     SizedBox(
//                                       width: 50,
//                                     ),
//                                     Icon(
//                                       Icons.task_alt,
//                                       color:  setCount >= 1 ? Colors.black : Colors.blue,
//                                       size: 50,
//                                     )
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           )
//         ],
//       ),
//     //   bottomNavigationBar: BottomNavigationBar(
//     //    items: const [
//     //      BottomNavigationBarItem(
//     //        icon: Icon(Icons.home),
//     //        label: 'Home',
//     //      ),
//     //      BottomNavigationBarItem(
//     //        icon: Icon(Icons.calendar_today),
//     //        label: 'Calendar',
//     //      ),
//     //    ],
//     //    currentIndex: _selectedIndex,
//     //    selectedItemColor: Color.fromARGB(255, 26, 154, 228),
//     //    onTap: _onItemTapped,
//     //  ),
//     );
//   }
// }