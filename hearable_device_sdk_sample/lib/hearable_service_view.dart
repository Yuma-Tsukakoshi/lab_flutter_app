import 'package:flutter/material.dart';
import 'package:hearable_device_sdk_sample/calendar.dart';
import 'package:hearable_device_sdk_sample/result.dart';
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

import 'package:hearable_device_sdk_sample_plugin/hearable_device_sdk_sample_plugin.dart';
import 'dart:math' as math;

import 'package:hearable_device_sdk_sample/lineChart.dart';
import 'package:hearable_device_sdk_sample/pricePoints.dart';

import 'dart:async';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

class HearableServiceView extends StatelessWidget {
  const HearableServiceView({super.key});

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


// タイマー終了時のコールバック型定義
typedef OnEndedCallback = Function();

// 定期的に経過時間を通知するためのコールバック型定義
typedef OnTickedCallback = Function(MyTimer);

class MyTimer {
  // タイマーを開始してから停止までの時間
  final Duration _timeLimit;
  
  // [_tick]毎に[_onTickedCallback]で通知を行う
  final Duration _tick;
  
  // 経過時間[_elapsed]が[_timeLimeit]以上になったときに呼ばれるコールバック
  final OnEndedCallback _onEndedCallback;
  
  // [_tick]毎に呼ばれるコールバック
  final OnTickedCallback _onTickedCallback;
  
  // 内部で使用するタイマー
  Timer? _timer;
  
  // 経過時間
  Duration _elapsed = Duration(seconds: 0);

  MyTimer(
    this._timeLimit,
    this._tick,
    this._onEndedCallback,
    this._onTickedCallback,
  );
  
  // 経過時間を取得するgetter
  Duration get elapsedTime => _elapsed; 

  // タイマーを開始するメソッド
  void start() {
    if(_timer == null){
      _timer = Timer.periodic(_tick, _onTicked);
    }
  }

  // タイマーを停止するメソッド
  // タイマーを停止した場合は[_onEndedCallback]は呼ばれない
  void stop() {
    if (_timer != null) {
      _timer!.cancel();
    }
  }
  
  // [_elapsed]を更新して[_onTickedCallback]を呼び出す
  // 終了判定も行う
  void _onTicked(Timer t) {
    this._elapsed += _tick;
    this._onTickedCallback(this);

    if (this._elapsed >= this._timeLimit) {
      _onEndedCallback();
      t.cancel();
    }
  }
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

  List<int> xValues = [];
  List<int> zValues = [];
  Timer? timer;

  int _counter = 0;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startTraining() {
    // リストをクリア
    _counter = 10;
    xValues.clear();
    zValues.clear();
    // 20秒のタイマーを設定
    // timer = Timer.periodic(Duration(milliseconds: 100), (timer) {

    timer = Timer.periodic(Duration(seconds: 1), (timer) {
       _counter--;
        setState(() {});

        if (_counter==0){
        // Excelファイルに保存
        saveToExcel();
        // タイマーを停止
        timer.cancel();
      }
    });

    // 9軸センサのデータをリストに追加する処理
    // 実際にはセンサからのデータ取得方法に置き換えてください
    // Timer.periodic(Duration(c), (timer) {
    //   if (!timer.isActive) return; // タイマーが停止していたら何もしない
    //   setState(() {
    //     xValues.add(NineAxisSensor().getResultString()); // 仮のメソッド
    //     zValues.add(NineAxisSensor().getResultStringZ()); // 仮のメソッド
    //   });
    // });
  }

Future<void> saveToExcel() async {
  var excel = Excel.createExcel();
  Sheet sheetObject = excel['Sheet1'];

  // データをExcelに追加
  for (int i = 0; i < xValues.length; i++) {
    var row = i + 1; // Excelの行は1から始まる
    sheetObject.cell(CellIndex.indexByString("A$row")).value = IntCellValue(xValues[i]);
    sheetObject.cell(CellIndex.indexByString("B$row")).value = IntCellValue(zValues[i]);
  }

  // ファイルを保存
  var fileBytes = excel.save();
  String directoryPath = (await getApplicationDocumentsDirectory()).path;
  print(directoryPath);
  File file = File("$directoryPath/training_data.xlsx");
  file.writeAsBytes(fileBytes!);

  print("Excelファイルを保存しました: $directoryPath/training_data.xlsx");
}

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
        
      } else if (index == 1) {
        // Calendar画面に遷移
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
    //int gyrX;
    int x_num = NineAxisSensor().getResultString();
    int z_num = NineAxisSensor().getResultStringZ();

    return Scaffold(
      appBar: AppBar(
        //leadingWidth: SizeConfig.blockSizeHorizontal * 20,
        //leading: Widgets.barBackButton(context),
        title: const Text('トレーニングセンサデータ確認', style: TextStyle(fontSize: 16)),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(48, 116, 187, 10),
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
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => {_saveInput(context)},
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    // 9軸センサ
                    const SizedBox(
                      height: 20,
                    ),
                    Consumer<NineAxisSensor>(
                        builder: ((context, nineAxisSensor, _) =>
                            Widgets.switchContainer(
                                title: '9軸センサ',
                                enable: nineAxisSensor.isEnabled,
                                function: _switch9AxisSensor))),
                    const SizedBox(height: 5),

                    Consumer<NineAxisSensor>(
                        builder: ((context, nineAxisSensor, _) =>
                            Widgets.resultContainer(
                              verticalRatio: 40,
                              controller: nineAxisSensorResultController,
                              text: ' x: ' +
                                  nineAxisSensor.getResultString().toString() +
                                  ' ,  z:  ' +
                                  nineAxisSensor.getResultStringZ().toString() +
                                  '  ',
                            ))
                    ),

                    // Center(
                    //   child: LineChartWidget(pricePoints),
                    // ),
                    // const SizedBox(height: 20),

                    //ユーザー側の出力
                    if ((x_num > -500 && x_num < 500) && z_num > 200) ...{
                      Text("自分：上"),
              
                    } else if ((x_num > -500 && x_num < 500) &&
                        z_num < -200) ...{
                      Text("自分：下"),
        
                    } else if ((z_num > -500 && z_num < 500) &&
                        x_num > 200) ...{
                      Text("自分：左"),
 
                    } else if ((z_num > -500 && z_num < 500) &&
                        x_num < -200) ...{
                      Text("自分：右"),
                      
                    } else ...{
                      Text("自分：正面"),
                     
                    },

                    const SizedBox(height: 20),
                    /*Consumer<NineAxisSensor>(
                    builder: ((context, nineAxisSensor, _) =>
                        Widgets.resultContainerPhoto(
                            verticalRatio: 40,
                            controller: nineAxisSensorResultController,
                            text:  nineAxisSensor.getResultString().toString(),
                            photo: nineAxisSensor.getResultString().toString()
                            
                            
                            //NineAxisSensor().gyrx<30000 ?Image.asset('assets/penguin_up.jpeg'):Image.asset('assets/penguin_up.jpeg'),
                            /*if(nineAxisSensor.getResultString()>30000){
                              String a=assets/penguin_down.jpeg;
                            }*/
                            ))
                            ),
                          */
                    //if
                    //NineAxisSensor().getResultString()<30000 ?Image.asset('assets/penguin_down.jpeg'):Image.asset('assets/penguin_up.jpeg'),
 
                    /*Consumer<NineAxisSensor>(
                    builder: ((context, nineAxisSensor, _) =>
                        Widgets.resultContainer(
                            verticalRatio: 40,
                            controller: nineAxisSensorResultController,
                            text: nineAxisSensor.getResultString().toString()
                            //NineAxisSensor().getResultString()<30000 ?Image.asset('assets/penguin_down.jpeg'):Image.asset('assets/penguin_up.jpeg'),

                            /*if(nineAxisSensor.getResultString()>30000){
                              String a=assets/penguin_down.jpeg;
                            }*/
                            ))
                            ),*/
                    Text(
                        'X:' +
                            x_num.toString() +
                            " "
                                'Z:' +
                            z_num.toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20)
                    ),
                    // 9軸センサ
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Card(
                          child: Container(
                            width: 320,
                            height: 80,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center, // 上下中央に配置
                                children: [
                                  Text(
                                    '種目',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10), 
                                  Text(
                                    '腕立て伏せ',
                                    style: TextStyle(
                                      fontSize: 20,
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
                    const SizedBox(height: 20),
                    Image.asset('assets/udetate.png', height: 220, width: 320),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Card(
                          child: Container(
                            width: 150,
                            height: 100,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center, // 上下中央に配置
                                children: [
                                  Text(
                                    'セット数',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10), 
                                  Text(
                                    ' 残り 1セット ',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                        Card(
                          child: Container(
                            width: 150,
                            height: 100,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center, // 上下中央に配置
                                children: [
                                  Text(
                                    '残り回数',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10), 
                                  Text(
                                    ' 12 ',
                                    style: TextStyle(
                                      fontSize: 20,
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

                    Text(_counter.toString()),
                    
                    ElevatedButton(
                      onPressed: () {
                        startTraining();
                      },
                      
                      child: const Text('トレーニングを開始する',
                          style: TextStyle(   
                            fontSize: 20,
                            color: Colors.white
                          )),
                          style: ElevatedButton.styleFrom(
                            primary: Color.fromARGB(161, 243, 39, 39),
                          ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return Result();
                        }));
                      },
                      child: const Text('トレーニングを終了する',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white
                          )),
                          style: ElevatedButton.styleFrom(
                            primary: Color.fromARGB(162, 163, 193, 218),
                          ),
                    ),
                  ],
                ),
              ),
            ),
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
/*if(NineAxisSensor().getResultString()<30000){
                  children.add(Image.asset('assets/penguin_down.jpeg'));
                  }else {
                    children.add(Image.asset('assets/penguin_down.jpeg'));
                  }

                return Column(
                  children: children,
                )*/

/*
                Padding(
                  padding: const EdgeInsets.all(10),
                  // ユーザUUID
                  child: Row(children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 10, left: 30),
                      child: Text(
                        'ユーザUUID',
                        style: WidgetConfig.boldTextStyle,
                      ),
                    ),
                    SizedBox(width: SizeConfig.blockSizeHorizontal * 10),
                    // UUID生成ボタン
                    ElevatedButton(
                        onPressed: _createUuid,
                        style: WidgetConfig.buttonStyle,
                        child: const Text(
                          '生成',
                          style: WidgetConfig.buttonTextStyle,
                        ))
                  ]),
                ),
                Text(
                  userUuid,
                  style: WidgetConfig.uuidTextStyle,
                ),
                const SizedBox(height: 20),
                Widgets.inputNumberContainer(
                    title: '特徴量取得必要回数',
                    unit: '回',
                    horizontalRatio: 15,
                    controller: featureRequiredNumController,
                    function: _onSavedFeatureRequiredNum),
                const SizedBox(height: 20),
                // 特徴量取得・登録、キャンセル
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: SizeConfig.blockSizeHorizontal * 40,
                      // 取得・登録ボタン
                      child: ElevatedButton(
                        onPressed: _feature,
                        style: WidgetConfig.buttonStyle,
                        child: const Text(
                          '特徴量取得＆登録',
                          style: WidgetConfig.buttonTextStyle,
                        ),
                      ),
                    ),
                    SizedBox(width: SizeConfig.blockSizeHorizontal * 5),
                    SizedBox(
                      width: SizeConfig.blockSizeHorizontal * 40,
                      // 登録キャンセルボタン
                      child: ElevatedButton(
                        onPressed: _cancelRegistration,
                        style: WidgetConfig.buttonStyle,
                        child: const Text(
                          'キャンセル',
                          style: WidgetConfig.buttonTextStyle,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        '特徴量取得回数',
                        style: WidgetConfig.boldTextStyle,
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Consumer<Eaa>(
                            builder: ((context, eaa, _) =>
                                Text('${eaa.featureGetCount} 回'))))
                  ],
                ),
                const SizedBox(height: 20),
                // 照合、状態取得
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: SizeConfig.blockSizeHorizontal * 40,
                      // 照合ボタン
                      child: ElevatedButton(
                        onPressed: _verify,
                        style: WidgetConfig.buttonStyle,
                        child: const Text(
                          '照合',
                          style: WidgetConfig.buttonTextStyle,
                        ),
                      ),
                    ),
                    SizedBox(width: SizeConfig.blockSizeHorizontal * 5),
                    SizedBox(
                      width: SizeConfig.blockSizeHorizontal * 40,
                      // 状態取得ボタン
                      child: ElevatedButton(
                        onPressed: _requestRegisterStatus,
                        style: WidgetConfig.buttonStyle,
                        child: const Text(
                          '登録状態',
                          style: WidgetConfig.buttonTextStyle,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  alignment: Alignment.topLeft,
                  child: const Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Text(
                      '登録ユーザUUID',
                      style: WidgetConfig.boldTextStyle,
                    ),
                  ),
                ),
                SizedBox(
                    width: SizeConfig.blockSizeHorizontal * 85,
                    height: SizeConfig.blockSizeVertical * 20,
                    child: Consumer<Eaa>(
                        builder: ((context, eaa, _) =>
                            _createUserListView(context)))),
                const SizedBox(height: 10),
                // ユーザー登録削除、全削除
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: SizeConfig.blockSizeHorizontal * 40,
                      // ユーザー登録削除ボタン
                      child: ElevatedButton(
                        onPressed: _deleteRegistration,
                        style: WidgetConfig.buttonStyle,
                        child: const Text(
                          'ユーザー削除',
                          style: WidgetConfig.buttonTextStyle,
                        ),
                      ),
                    ),
                    SizedBox(width: SizeConfig.blockSizeHorizontal * 5),
                    SizedBox(
                      width: SizeConfig.blockSizeHorizontal * 40,
                      // 全削除ボタン
                      child: ElevatedButton(
                        onPressed: _deleteAllRegistration,
                        style: WidgetConfig.buttonStyle,
                        child: const Text(
                          '全削除',
                          style: WidgetConfig.buttonTextStyle,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Consumer<Eaa>(
                    builder: ((context, eaa, _) => Widgets.resultContainer(
                        verticalRatio: 25,
                        controller: eaaResultController,
                        text: eaa.resultStr))),
                const SizedBox(height: 20),*/

/*           ),
          ),
        ),
      ),
    );
  }
  
}
*/

/*int getRandomNum() {
  //ランダム変数生成
  var random = math.Random();
  int randomNumber = random.nextInt(5); // 0から4の範囲で乱数を生成
  //print(randomNumber);
  return randomNumber;
}
*/