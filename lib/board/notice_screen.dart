import 'package:flutter/material.dart';

class NoticePage extends StatefulWidget {
  const NoticePage({Key? key}) : super(key: key);

  @override
  _NoticePageState createState() => _NoticePageState();
  }

  class _NoticePageState extends State<NoticePage> {
  Color myColor = const Color(0xFFF8B195);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: myColor,
        title: const Text('공지사항'),
      ),
      body: const Center(
        child: Text('This is Notice page'),
      ),
    );
  }
}