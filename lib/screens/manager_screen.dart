import 'package:Aily/screens/home_screen.dart';
import 'package:Aily/screens/map_screen.dart';
import 'package:flutter/material.dart';
import 'package:Aily/utils/ShowDialog.dart';
import 'package:gradients/gradients.dart';

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
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          children: [
            const SizedBox(height: 60),
            const Text(
              '관리자',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 45),
            Row(
              children: [
                buildNavigationContainer(
                  context,
                  '위치',
                  Icons.location_on,
                  const MapScreen(),
                ),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 10.0)),
                buildNavigationContainer(
                  context,
                  '화면2',
                  Icons.settings,
                  const HomeScreen(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                buildNavigationContainer(
                  context,
                  '화면3',
                  Icons.settings,
                  const MapScreen(),
                ),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 10.0)),
                buildNavigationContainer(
                  context,
                  '화면4',
                  Icons.settings,
                  const MapScreen(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                buildNavigationContainer(
                  context,
                  '화면5',
                  Icons.settings,
                  const MapScreen(),
                ),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 10.0)),
                buildNavigationContainer(
                  context,
                  '화면6',
                  Icons.settings,
                  const MapScreen(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildNavigationContainer(
    BuildContext context,
    String title,
    IconData icon,
    Widget page
    ) {
  var screenWidth = MediaQuery.of(context).size.width * 0.423;
  var screenHeight = MediaQuery.of(context).size.height * 0.217;
  Color containerColor = const Color(0xFF87A7dD);

  return GestureDetector(
    onTap: () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => page));
    },
    child: Container(
      width: screenWidth,
      height: screenHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradientPainter(
            colors: [containerColor, containerColor, containerColor]
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 40,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.bold
            ),
          ),
        ],
      ),
    ),
  );
}

