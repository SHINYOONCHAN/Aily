import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:Aily/utils/ShowDialog.dart';
import 'package:Aily/proves/mapTitleProvider.dart';
import 'package:Aily/screens/garbage_screen.dart';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:provider/provider.dart';
import 'package:Aily/proves/testUserProvider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String phoneNumber;
  late MySqlConnection conn;

  File? _image;
  Uint8List? _imageData;
  List<String> SelectedTitles = [];

  late String? username;
  late int? userpoint;
  late Uint8List? profile;
  Color myColor = const Color(0xFFF8B195);

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  @override
  void dispose() {
    conn.close();
    super.dispose();
  }

  void _getUser() {
    final UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    username = userProvider.user.nickname;
    userpoint = userProvider.user.point;
    setState(() {

    });
  }

  void _getListTitle() {
    final TitleProvider titleProvider = Provider.of<TitleProvider>(context, listen: true);
    final titles = titleProvider.title.title;
    setState(() {
      SelectedTitles = titles;
    });
    addMarker(SelectedTitles);
    print(SelectedTitles);
  }

  Future<void> uploadImageToServer(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final imgData = bytes.toList();

      final rows = await conn.query(
          'SELECT username FROM sign WHERE username = ?', [username]);
      if (rows.isNotEmpty) {
        await conn.query(
          'UPDATE sign SET image = ? WHERE username = ?',
          [imgData, username],
        );
      } else {
        await conn.query(
          'INSERT INTO sign (username, image) VALUES (?, ?)',
          [username, imgData],
        );
      }
      downloadImageFromServer(username!);
    } catch (e) {
      showMsg(context, "오류", '업로드 실패: $e');
    }
  }

  Future<void> downloadImageFromServer(String id) async {
    try {
      final result = await conn.query(
          'SELECT image FROM sign WHERE username = ?', [id]);
      if (result.isNotEmpty) {
        final rowData = result.first;
        final imgData = rowData['image'] as Blob;
        final bytes = imgData.toBytes();
        setState(() {
          profile = bytes as Uint8List?;
        });
      }
    } catch (e) {
      showMsg(context, "오류", '다운로드 실패');
    } finally {}
  }

  List<String> selectedMarkers = [];

  void addMarker(List<String> titles) {
    setState(() {
      selectedMarkers = [...selectedMarkers, ...titles];
    });
  }

  Widget _buildListTiles() {
    List<Widget> listTiles = [];
    for (var title in selectedMarkers) {
      listTiles.add(_ListTile(context, title));
    }
    return Column(children: listTiles);
  }

  @override
  Widget build(BuildContext context) {
    Color backColor = const Color(0xFFF6F1F6);

    return Scaffold(
      backgroundColor: backColor,
      body: HomeWidget(username!, context),
    );
  }

  Widget HomeWidget(String username, BuildContext context) {
    _getListTitle();

    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                    Positioned(
                      top: 5,
                      left: 20,
                      child: Text(
                        "AILY",
                        style: TextStyle(
                          fontSize: 35,
                          fontFamily: 'Waiting for the Sunrise',
                          fontWeight: FontWeight.bold,
                          color: myColor,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 13,
                      left: 295,
                      child: GestureDetector(
                        onTap: () {
                          // 클릭 시 실행될 코드
                          showMsg(context, "테스트", "테스트");
                        },
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/icons/alarm.png', // 이미지 파일 경로
                              width: 40, // 이미지 크기
                              height: 40,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 15,
                      left: 30,
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/images/icons/wallet.png',
                            width: 20,
                            height: 20,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            username,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            '님의 포인트',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                          Text(
                            '$userpoint',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          ElevatedButton(
                            onPressed: (){
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: const Color.fromARGB(210, 248, 177, 149),
                              padding: const EdgeInsets.symmetric(vertical: 13.0, horizontal: 130.0),
                            ),
                            child: const Text('적립내역', style: TextStyle(fontSize: 15)
                            ),
                          ),
                        ],
                      )
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: SingleChildScrollView(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10), // 모서리를 둥글게 지정
                          ),
                          child: Column(
                            children: [
                              _buildListTiles()
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
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

Widget _ListTile(BuildContext context, String title){
  Color myColor = const Color(0xFFF8B195);

  return ListTile(
    title: Text(title),
    subtitle: const Text('일반, 캔, 페트'),
    trailing: ElevatedButton(
      onPressed: (){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GarbageScreen(title: title),
          ),
        );

      },
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
          side: BorderSide(
            color: myColor,
            width: 1.5,
          ),
        ),
      ),
      child: const Text('상세', style: TextStyle(color: Colors.black)),
    ),
  );
}
