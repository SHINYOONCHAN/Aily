import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRScreen extends StatefulWidget {
  const QRScreen({Key? key}) : super(key: key);

  @override
  _QRScreenState createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  Color myColor = const Color(0xFFF8B195);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final qrSize = screenWidth * 0.75;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: myColor,
        title: const Text('QR'),
      ),
      body: Center(
        child: QrImage(
          data: "01033567286",
          version: QrVersions.auto,
          size: qrSize,
        ),
      ),
    );
  }
}