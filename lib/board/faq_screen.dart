import 'package:flutter/material.dart';

class FAQPage extends StatefulWidget {
  const FAQPage({Key? key}) : super(key: key);

  @override
  _FAQPageState createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  Color myColor = const Color(0xFFF8B195);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: myColor,
        title: const Text('FAQ'),
      ),
      body: const Center(
        child: Text('This is FAQ page'),
      ),
    );
  }
}