import 'package:flutter/material.dart';
import 'package:hearable_device_sdk_sample/calendar.dart';


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
              const SizedBox(height: 40),

              Center(
                child:SizedBox(
                  width: 200, //横幅
                  height: 60, //高さ
                  child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Calendar(),
                      ),
                    );
                  },
                  child: Text('今日の達成率確認',
                  style: TextStyle(
                    color:Colors.white,
                    fontSize: 18,
                  )),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                    maximumSize: Size(200, 50),
                    onPrimary: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),  
                ),
                ),
              ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
