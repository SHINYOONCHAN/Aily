import 'dart:typed_data';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:Aily/screens/account_screen.dart';
import 'package:Aily/screens/map_screen.dart';
import 'package:flutter/material.dart';
import '../screens/point_screen.dart';
import '../screens/qr_Screen.dart';
import '../screens/home_screen.dart';

class NavigatorScreen extends StatefulWidget {
  const NavigatorScreen({Key? key}) : super(key: key);

  @override
  _NavigatorScreenState createState() => _NavigatorScreenState();
}

class _NavigatorScreenState extends State<NavigatorScreen> with TickerProviderStateMixin{
  Color myColor = const Color(0xFFF8B195);
  String _qrCode = '';
  late String? username;
  late Uint8List? profile;
  late List<Widget> _children;
  late AnimationController _animationController;
  late Animation<double> _animation;
  int _currentIndex = 0;
  final PageController pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _animation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    _animationController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Future<void> _scanQRCode() async {
  //   String qrCode = await FlutterBarcodeScanner.scanBarcode(
  //     '#ff6666',
  //     '취소',
  //     true,
  //     ScanMode.QR,
  //   );
  //
  //   setState(() {
  //     _qrCode = qrCode;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    _children = [
      const HomeScreen(),
      const PointScreen(),
      const MapScreen(),
      const Account_screen()
    ];

    return Scaffold(
      body: PageView(
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
        children: _children.map((e) => FadeTransition(
          opacity: _animation,
          child: e,
        )).toList(),
      ),

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.079,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              TextButton.icon(
                icon: const Icon(Icons.home),
                label: const Text('홈'),
                style: TextButton.styleFrom(
                  foregroundColor: _currentIndex == 0 ? myColor : Colors.grey,
                ),
                onPressed: () {
                  _onTap(0);
                },
              ),
              TextButton.icon(
                icon: const Icon(Icons.control_point_duplicate),
                label: const Text('포인트'),
                style: TextButton.styleFrom(
                  foregroundColor: _currentIndex == 1 ? myColor : Colors.grey,
                ),
                onPressed: () {
                  _onTap(1);
                },
              ),
              const SizedBox(width: 48.0),
              TextButton.icon(
                icon: const Icon(Icons.location_on),
                label: const Text('지도'),
                style: TextButton.styleFrom(
                  foregroundColor: _currentIndex == 2 ? myColor : Colors.grey,
                ),
                onPressed: () {
                  _onTap(2);
                },
              ),
              TextButton.icon(
                icon: const Icon(Icons.person),
                label: const Text('내 정보'),
                style: TextButton.styleFrom(
                  foregroundColor: _currentIndex == 3 ? myColor : Colors.grey,
                ),
                onPressed: () {
                  _onTap(3);
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const QRScreen(),
            ),
          );
        },
        backgroundColor: myColor,
        highlightElevation: 0,
        splashColor: Colors.red,
        child: Image.asset('assets/images/QR.png', width: 30, height: 30),
      ),
    );
  }

  void onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onTap(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
      _animationController.forward(from: 0.0);
      pageController.jumpToPage(index);
    }
  }
}