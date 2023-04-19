import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
import '../proves/testUserProvider.dart';

class QRScreen extends StatefulWidget {
  const QRScreen({Key? key}) : super(key: key);

  @override
  _QRScreenState createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  Color myColor = const Color(0xFFF8B195);
  late int phonenumber;

  @override
  void initState() {
    super.initState();
    _getPhone();
  }

  Future<void> _getPhone() async {
    final UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    setState(() {
      phonenumber = userProvider.user.phonenumber;
    });
  }

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
          data: "$phonenumber",
          version: QrVersions.auto,
          size: qrSize,
        ),
      ),
    );
  }
}