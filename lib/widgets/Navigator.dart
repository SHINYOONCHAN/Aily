import 'dart:typed_data';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:Aily/screens/account_screen.dart';
import 'package:Aily/screens/map_screen.dart';
import 'package:flutter/material.dart';
import '../screens/point_screen.dart';
import '../screens/qr_Screen.dart';
import '../screens/home_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    Widget _IconButton(String icon, int index) {
      return Column(
        children: [
          IconButton(
            icon: SvgPicture.asset(
              'assets/images/$icon.svg',
              color: _currentIndex == index ? myColor : Colors.grey,
            ),
            onPressed: () {
              _onTap(index);
            },
          ),
        ],
      );
    }

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
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.08,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const SizedBox(width: 20.0),
              _IconButton('home_icon', 0),
              const SizedBox(width: 10.0),
              _IconButton('story_icon', 1),
              const SizedBox(width: 100.0),
              _IconButton('map_icon', 2),
              const SizedBox(width: 10.0),
              _IconButton('profile_tab_icon', 3),
              const SizedBox(width: 20.0),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const QRScreen(),
            ),
          );
        },
        backgroundColor: myColor,
        foregroundColor: Colors.white,
        elevation: 5.0,
        child: const Icon(Icons.qr_code, size: 40.0),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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

