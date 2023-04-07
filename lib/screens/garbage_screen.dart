import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';

class GarbageScreen extends StatefulWidget {
  final String title;
  const GarbageScreen({Key? key, required this.title}) : super(key: key);

  @override
  _GarbageScreenState createState() => _GarbageScreenState();
}

class _GarbageScreenState extends State<GarbageScreen> {
  int _normalAmount = 0;
  int _plasticAmount = 0;
  int _canAmount = 0;
  double _normalHeightPercent = 1.0,
      _canHeightPercent = 1.0,
      _plasticHeightPercent = 1.0;

  late MySqlConnection conn;
  //late String? title;
  Color myColor = const Color(0xFFF8B195);

  Future<void> fetchGarbage() async {
    final results = await conn.query('SELECT * FROM garbage');

    final data = <Map<String, dynamic>>[];
    for (var result in results) {
      data.add({
        'normal': result[0],
        'can': result[1],
        'plastic': result[2],
      });
    }

    setState(() {
      _normalAmount = data[0]['normal'];
      _normalHeightPercent = HeightPercentage(_normalAmount);

      _canAmount = data[0]['can'];
      _canHeightPercent = HeightPercentage(_canAmount);

      _plasticAmount = data[0]['plastic'];
      _plasticHeightPercent = HeightPercentage(_plasticAmount);
    });
  }

  double HeightPercentage(int n) {
    return 1.0 - ((n / 50.0) * 0.55);
  }

  @override
  void initState() {
    super.initState();
    MySqlConnection.connect(
      ConnectionSettings(
        host: '211.201.93.173',
        //'175.113.68.69',
        port: 3306,
        user: 'root',
        password: '488799',
        db: 'database',
      ),
    ).then((connection) {
      conn = connection;
      Timer.periodic(const Duration(seconds: 3), (timer) => fetchGarbage());
    });
  }

  @override
  void dispose() {
    conn.close();
    super.dispose();
  }

  void _gettitle() {
    // final UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    // title = userProvider.user.username;
    //setState((){});
  }

  @override
  Widget build(BuildContext context) {
    Color backColor = const Color(0xFFF6F1F6);

    return Scaffold(
      backgroundColor: backColor,
      body: GarbageWidget(context),
    );
  }

  Widget GarbageWidget(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Column(
          children: [
            const SizedBox(height: 55),
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 300,
                                height: 50,
                                child: Text('${widget.title} Aily', style: const TextStyle(color: Color(0xff353E5E), fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ), // 홍대입구역 로우
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: const [
                            SizedBox(
                              height: 35,
                              width: 100,
                              child: Text(
                                '상세정보',
                                style: TextStyle(
                                    color: Color(
                                      0xff353E5E,
                                    ),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ), // 상세정보 로우
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 307,
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(45),
                                color: const Color(0xffF8B195),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 70),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildGarbageCan('일반', _normalAmount, _normalHeightPercent),
                            _buildGarbageCan('캔', _canAmount, _canHeightPercent),
                            _buildGarbageCan('플라스틱', _plasticAmount, _plasticHeightPercent),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
          ],
         ),
      ),
    );
  }
}

Widget _buildGarbageCan(String label, int amount, double heightval) {
  final percent = amount / 100;
  Color gradientColor = const Color(0xffF67280);

  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        label,
        style: const TextStyle(
          color: Color(0xff353E5E),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 10),
      Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 80,
            height: 160,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  LiquidLinearProgressIndicator(
                    value: percent,
                    backgroundColor: Colors.white,
                    borderColor: gradientColor,
                    borderWidth: 3.0,
                    borderRadius: 25.0,
                    direction: Axis.vertical,
                    valueColor: AlwaysStoppedAnimation<Color>(gradientColor),
                  ),
                  Positioned(
                    top: 65,
                    left: 0,
                    right: 0,
                    child: Text(
                      '${(percent * 100).toInt()}%',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ],
  );
}