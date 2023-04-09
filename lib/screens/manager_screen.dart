import 'package:flutter/material.dart';

class ManagerScreen extends StatefulWidget {
  const ManagerScreen({Key? key}) : super(key: key);

  @override
  _ManagerScreenState createState() => _ManagerScreenState();
}

class _ManagerScreenState extends State<ManagerScreen> {
  Color myColor = const Color(0xFFF8B195);
  Color backColor = const Color(0xFFF6F1F6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backColor,
      body: ManagerWidget(context),
    );
  }

  Widget ManagerWidget(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width * 0.423;
    var screenHeight = MediaQuery.of(context).size.height * 0.217;

    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          children: [
            const SizedBox(height: 45),
            const Text(
              '관리자',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Container(
                  width: screenWidth,
                  height: screenHeight,
                  color: Colors.white,
                  child: const Center(
                    child: Text('화면1', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                  ),
                ),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 10.0)),
                Container(
                  width: screenWidth,
                  height: screenHeight,
                  color: Colors.white,
                  child: const Center(
                    child: Text('화면2', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: screenWidth,
                  height: screenHeight,
                  color: Colors.white,
                  child: const Center(
                    child: Text('화면3', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                  ),
                ),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 10.0)),
                Container(
                  width: screenWidth,
                  height: screenHeight,
                  color: Colors.white,
                  child: const Center(
                    child: Text('화면4', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}