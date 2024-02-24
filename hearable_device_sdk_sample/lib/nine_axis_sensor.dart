import 'package:flutter/foundation.dart';
import 'package:hearable_device_sdk_sample_plugin/hearable_device_sdk_sample_plugin.dart';
import 'dart:math' as math;

class NineAxisSensor extends ChangeNotifier {
  final HearableDeviceSdkSamplePlugin _samplePlugin =
      HearableDeviceSdkSamplePlugin();
  bool isEnabled = false;

  int? _resultCode;
  Uint8List? _data;

  static final NineAxisSensor _instance = NineAxisSensor._internal();

  factory NineAxisSensor() {
    return _instance;
  }

  NineAxisSensor._internal();

  int? get resultCode => _resultCode;
  Uint8List? get data => _data;
  int gyrx = 0;
  int gyrz = 0;

  int getRandomNum() {
    //ランダム変数生成
    var random = math.Random();
    int randomNumber = random.nextInt(5); // 0から4の範囲で乱数を生成
    //print(randomNumber);
    return randomNumber;
  }

  int getResultString() {
    String str = '';

    if (_resultCode != null) {
      str += 'result code: $_resultCode';
    }

    if (_data != null) {
      str += '\nbyte[]:\n';
      Uint8List data = _data!;
      for (int i = 0; i < data.length - 1; i++) {
        str += '${data[i]}, ';
      }
      str += data.last.toRadixString(16);

      //X
      String upperBitsX = data[11].toRadixString(16); // 上位8ビット
      String lowerBitsX = data[12].toRadixString(16); // 下位8ビット

      String fullnumX = "$upperBitsX$lowerBitsX";
      int decimalValueX = int.parse(fullnumX, radix: 16); // 16進数を10進数に変換
      print(decimalValueX);
      if (decimalValueX > 23767) {
        decimalValueX -= 65536;
      }
      if (decimalValueX.abs() < 60) {
        return 0;
      }

      gyrx = decimalValueX;

      //Y
      String upperBitsY = data[13].toRadixString(16); // 上位8ビット
      String lowerBitsY = data[14].toRadixString(16); // 下位8ビット

      String fullnumY = "$upperBitsY$lowerBitsY";
      int decimalValueY = int.parse(fullnumY, radix: 16); // 16進数を10進数に変換
      print(decimalValueY);

      //Z
      String upperBitsZ = data[15].toRadixString(16); // 上位8ビット
      String lowerBitsZ = data[16].toRadixString(16); // 下位8ビット

      String fullnumZ = "$upperBitsZ$lowerBitsZ";
      int decimalValueZ = int.parse(fullnumZ, radix: 16); // 16進数を10進数に変換
      print(decimalValueZ);
      if (decimalValueZ > 23767) {
        decimalValueZ -= 65536;
      }
      gyrz = decimalValueZ;

      /*double deltaT = (decimalValueX / 100)*5 ;

      double a = deltaT;
      int delta = deltaT.toInt() ;*/

      //return delta;
      return decimalValueX;
      //return gyrx;
    } else {
      return 0;
    }

    //return decimalValueX.toString();
  }

//Copy
  int getResultStringZ() {
    String str = '';
    int i = 0;
    double a = 0;

    if (_resultCode != null) {
      str += 'result code: $_resultCode';
    }

    if (_data != null) {
      str += '\nbyte[]:\n';
      Uint8List data = _data!;
      for (i = 0; i < data.length - 1; i++) {
        str += '${data[i]}, ';
      }
      str += data.last.toRadixString(16);

      //X
      String upperBitsX = data[11].toRadixString(16); // 上位8ビット
      String lowerBitsX = data[12].toRadixString(16); // 下位8ビット

      String fullnumX = "$upperBitsX$lowerBitsX";
      int decimalValueX = int.parse(fullnumX, radix: 16); // 16進数を10進数に変換
      print(decimalValueX);

      gyrx = decimalValueX;

      //Y
      String upperBitsY = data[13].toRadixString(16); // 上位8ビット
      String lowerBitsY = data[14].toRadixString(16); // 下位8ビット

      String fullnumY = "$upperBitsY$lowerBitsY";
      int decimalValueY = int.parse(fullnumY, radix: 16); // 16進数を10進数に変換
      print(decimalValueY);

      //Z
      String upperBitsZ = data[15].toRadixString(16); // 上位8ビット
      String lowerBitsZ = data[16].toRadixString(16); // 下位8ビット

      String fullnumZ = "$upperBitsZ$lowerBitsZ";
      int decimalValueZ = int.parse(fullnumZ, radix: 16); // 16進数を10進数に変換
      print(decimalValueZ);
      if (decimalValueZ > 23767) {
        decimalValueZ -= 65536;
      }
      gyrz = decimalValueZ;

      if (decimalValueX > 23767) {
        decimalValueX -= 65536;
      }
      //角速度ー＞角度に補正

      // Δt [s](元のセンシング周期は単位がμsだったので、(1000.0 * 1000.0)で割ることで単位をsに変換)
      /*double deltaT = 5*decimalValueZ / 100 ;

      //double a = 0;
      a += deltaT ;
      int angz=a.toInt();

      return angz;*/

      return decimalValueZ;
    }
    //return decimalValueZ;
    //return gyrx;

    else {
      return 0;
    }
  }

  Future<bool> addNineAxisSensorNotificationListener() async {
    final res = await _samplePlugin.addNineAxisSensorNotificationListener(
        onStartNotification: _onStartNotification,
        onStopNotification: _onStopNotification,
        onReceiveNotification: _onReceiveNotification);
    return res;
  }

  void _removeNineAxisSensorNotificationListener() {
    _samplePlugin.removeNineAxisSensorNotificationListener();
  }

  void _onStartNotification(int resultCode) {
    _resultCode = resultCode;
    notifyListeners();
  }

  void _onStopNotification(int resultCode) {
    _removeNineAxisSensorNotificationListener();
    _resultCode = resultCode;
    notifyListeners();
  }

  void _onReceiveNotification(Uint8List? data, int resultCode) {
    _data = data;
    _resultCode = resultCode;
    notifyListeners();
  }
}
