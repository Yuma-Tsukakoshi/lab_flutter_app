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
  const Result({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: NineAxisSensor()),
        ChangeNotifierProvider.value(value: Temperature()),
        ChangeNotifierProvider.value(value: HeartRate()),
        ChangeNotifierProvider.value(value: Ppg()),
        ChangeNotifierProvider.value(value: Eaa()),
        ChangeNotifierProvider.value(value: Battery()),
      ],
      child: _HearableServiceView(),
    );
  }
}

class _HearableServiceView extends StatefulWidget {
  @override
  State<_HearableServiceView> createState() => _HearableServiceViewState();
}

class _HearableServiceViewState extends State<_HearableServiceView> {
  final HearableDeviceSdkSamplePlugin _samplePlugin =
      HearableDeviceSdkSamplePlugin();
  String userUuid = (Eaa().featureGetCount == 0)
      ? const Uuid().v4()
      : Eaa().registeringUserUuid;
  var selectedIndex = -1;
  var selectedUser = '';
  bool isSetEaaCallback = false;

  var config = Config();
  Eaa eaa = Eaa();

  TextEditingController featureRequiredNumController = TextEditingController();
  TextEditingController featureCountController = TextEditingController();
  TextEditingController eaaResultController = TextEditingController();

  TextEditingController nineAxisSensorResultController =
      TextEditingController();
  TextEditingController temperatureResultController = TextEditingController();
  TextEditingController heartRateResultController = TextEditingController();
  TextEditingController ppgResultController = TextEditingController();

  TextEditingController batteryIntervalController = TextEditingController();
  TextEditingController batteryResultController = TextEditingController();

  void _createUuid() {
    userUuid = const Uuid().v4();

    eaa.featureGetCount = 0;
    eaa.registeringUserUuid = userUuid;
    _samplePlugin.cancelEaaRegistration();

    setState(() {});
  }

  void _feature() async {
    eaa.registeringUserUuid = userUuid;
    _showDialog(context, '特徴量取得・登録中...');
    // 特徴量取得、登録
    if (!(await _samplePlugin.registerEaa(uuid: userUuid))) {
      Navigator.of(context).pop();
      // エラーダイアログ
      Alert.showAlert(context, 'Exception');
    }
  }

  void _deleteRegistration() async {
    _showDialog(context, '登録削除中...');
    // ユーザー削除
    if (!(await _samplePlugin.deleteSpecifiedRegistration(
        uuid: selectedUser))) {
      Navigator.of(context).pop();
      // エラーダイアログ
      Alert.showAlert(context, 'Exception');
    }
  }

  void _deleteAllRegistration() async {
    _showDialog(context, '登録削除中...');
    // ユーザー全削除
    if (!(await _samplePlugin.deleteAllRegistration())) {
      Navigator.of(context).pop();
      // エラーダイアログ
      Alert.showAlert(context, 'Exception');
    }
  }

  void _cancelRegistration() async {
    // 特徴量登録キャンセル
    if (!(await _samplePlugin.cancelEaaRegistration())) {
      // エラーダイアログ
      Alert.showAlert(context, 'IllegalStateException');
    }
  }

  void _verify() async {
    _showDialog(context, '照合中...');
    // 照合
    if (!(await _samplePlugin.verifyEaa())) {
      Navigator.of(context).pop();
      // エラーダイアログ
      Alert.showAlert(context, 'Exception');
    }
  }

  void _requestRegisterStatus() async {
    _showDialog(context, '登録状態取得中...');
    // 登録状態取得
    if (!(await _samplePlugin.requestRegisterStatus())) {
      Navigator.of(context).pop();
      // エラーダイアログ
      Alert.showAlert(context, 'Exception');
    }
  }

  void _switch9AxisSensor(bool enabled) async {
    NineAxisSensor().isEnabled = enabled;
    if (enabled) {
      // callback登録
      if (!(await NineAxisSensor().addNineAxisSensorNotificationListener())) {
        // エラーダイアログ
        Alert.showAlert(context, 'IllegalArgumentException');
        NineAxisSensor().isEnabled = !enabled;
      }
      // 取得開始
      if (!(await _samplePlugin.startNineAxisSensorNotification())) {
        // エラーダイアログ
        Alert.showAlert(context, 'IllegalStateException');
        NineAxisSensor().isEnabled = !enabled;
      }
    } else {
      // 取得終了
      if (!(await _samplePlugin.stopNineAxisSensorNotification())) {
        // エラーダイアログ
        Alert.showAlert(context, 'IllegalStateException');
        NineAxisSensor().isEnabled = !enabled;
      }
    }
    setState(() {});
  }

  // 選択可能なListView
  ListView _createUserListView(BuildContext context) {
    return ListView.builder(
        // 登録ユーザー数
        itemCount: eaa.uuids.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              selected: selectedIndex == index ? true : false,
              selectedTileColor: Colors.grey.withOpacity(0.3),
              title: Widgets.uuidText(eaa.uuids[index]),
              onTap: () {
                if (index == selectedIndex) {
                  _resetSelection();
                } else {
                  selectedIndex = index;
                  selectedUser = eaa.uuids[index];
                }
                setState(() {});
              },
            ),
          );
        });
  }

  void _showDialog(BuildContext context, String text) {
    showGeneralDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.5),
        pageBuilder: (BuildContext context, Animation animation,
            Animation secondaryAnimation) {
          return AlertDialog(
            content: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 10),
                    Text(text)
                  ],
                )
              ],
            ),
          );
        });
  }

  void _resetSelection() {
    selectedIndex = -1;
    selectedUser = '';
  }

  void _saveInput(BuildContext context) {
    var num = featureRequiredNumController.text;
    var interval = batteryIntervalController.text;

    if (num.isNotEmpty) {
      var num0 = int.parse(num);
      if (num0 >= 10 && num0 != config.featureRequiredNumber) {
        config.featureRequiredNumber = num0;
        _samplePlugin.setHearableEaaConfig(featureRequiredNumber: num0);
      }
    }
    _setRequiredNumText();

    if (interval.isNotEmpty) {
      var interval0 = int.parse(interval);
      if (interval0 >= 10 && interval0 != config.batteryNotificationInterval) {
        config.batteryNotificationInterval = interval0;
        _samplePlugin.setBatteryNotificationInterval(interval: interval0);
      }
    }
    _setBatteryIntervalText();

    setState(() {});
    FocusScope.of(context).unfocus();
  }

  void _onSavedFeatureRequiredNum(String? numStr) {
    if (numStr != null) {
      config.featureRequiredNumber = int.parse(numStr);
      _setRequiredNumText();
    }
    setState(() {});
  }

  void _onSavedBatteryInterval(String? intervalStr) {
    if (intervalStr != null) {
      config.batteryNotificationInterval = int.parse(intervalStr);
      _setBatteryIntervalText();
    }
    setState(() {});
  }

  void _setRequiredNumText() {
    featureRequiredNumController.text = config.featureRequiredNumber.toString();
    featureRequiredNumController.selection = TextSelection.fromPosition(
        TextPosition(offset: featureRequiredNumController.text.length));
  }

  void _setBatteryIntervalText() {
    batteryIntervalController.text =
        config.batteryNotificationInterval.toString();
    batteryIntervalController.selection = TextSelection.fromPosition(
        TextPosition(offset: batteryIntervalController.text.length));
  }

  void _registerCallback() {
    Navigator.of(context).pop();
  }

  void _deleteRegistrationCallback() {
    Navigator.of(context).pop();
    _resetSelection();
  }

  void __cancelRegistrationCallback() {
    eaa.featureGetCount = 0;
    setState(() {});
  }

  void _verifyCallback() {
    Navigator.of(context).pop();
  }

  void _getRegistrationStatusCallback() {
    Navigator.of(context).pop();
    _resetSelection();
  }

  int _selectedIndex = 0;
 
  void _onItemTapped(int index) {
  setState(() {
    _selectedIndex = index;
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HearableServiceView()),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Calendar()),
      );
    }
  });
}

  @override
  Widget build(BuildContext context) {
    _setRequiredNumText();
    _setBatteryIntervalText();

    if (!isSetEaaCallback) {
      eaa.addEaaListener(
          registerCallback: _registerCallback,
          cancelRegistrationCallback: null,
          deleteRegistrationCallback: _deleteRegistrationCallback,
          verifyCallback: _verifyCallback,
          getRegistrationStatusCallback: _getRegistrationStatusCallback);
      isSetEaaCallback = true;
    }


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
                                      color: Colors.blue,
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
                                      color: Colors.blue,
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
                                      color: Colors.black,
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