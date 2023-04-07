import 'dart:io';
import 'dart:typed_data';
import 'package:Aily/utils/ShowDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mysql1/mysql1.dart';
import 'package:Aily/proves/UserProvider.dart';
import 'package:provider/provider.dart';

class Account_screen extends StatefulWidget {
  const Account_screen({Key? key}) : super(key: key);

  @override
  _Account_screenState createState() => _Account_screenState();
}

class _Account_screenState extends State<Account_screen> {
  String _qrCode = '';
  late MySqlConnection conn;
  File? _image;
  late String? username;
  late Uint8List? profile;

  Future<void> _getUser() async {
    final UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    username = userProvider.user.username;
    profile = await userProvider.user.profile;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _getUser();
    MySqlConnection.connect(
      ConnectionSettings(
        host: '211.201.93.173',//'175.113.68.69',
        port: 3306,
        user: 'root',
        password: '488799',
        db: 'user_db',
      ),
    ).then((connection) {
      conn = connection;
    });
  }

  @override
  void dispose() {
    conn.close();
    super.dispose();
  }

  Future<void> _scanQRCode() async {
    String qrCode = await FlutterBarcodeScanner.scanBarcode(
      '#ff6666',
      '취소',
      true,
      ScanMode.QR,
    );

    setState(() {
      _qrCode = qrCode;
    });
  }

  void _profileUpdate(){
    final UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.updateProfile(profile!);
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _image = File(pickedFile.path);
        profile = bytes;
        _profileUpdate();
      });
    }
    if (_image == null) {
      return;
    }
    try {
      await uploadImageToServer(_image!);
    } catch (e) {
      showMsg(context, "오류", '업로드 실패');
    } finally {
    }
  }

  Future<void> uploadImageToServer(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final imgData = bytes.toList();

      final rows = await conn.query('SELECT username FROM sign WHERE username = ?',[username]);
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
    } catch (e) {
      showMsg(context, "오류", '업로드 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    Color backColor = const Color(0xFFF6F1F6);

    return Scaffold(
      backgroundColor:backColor,
      body: AccountWidget(username!, context),
    );
  }
  Widget AccountWidget(String username, BuildContext context) {
    return Padding(
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
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 250,
                      child: Stack(
                        children: [
                          const Positioned(
                            top: 25,
                            left: 20,
                            child: Text(
                              '프로필',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 30,
                            right: 18,
                            child: GestureDetector(
                              onTap: () {
                                showMsg(context, '설정', '설정');
                              },
                              child: const Icon(
                                Icons.settings,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 70,
                            left: 10,
                            right: 0,
                            child: ListTile(
                              horizontalTitleGap: 5,
                              leading: CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  backgroundColor: Colors.transparent,
                                  child: ClipOval(
                                    child: Image.memory(
                                      profile!,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(username, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black),
                              onTap: () {
                                _pickImage(ImageSource.gallery);
                                //showMsg(context, '프로필', '프로필');
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    ListTile(
                      leading: const Icon(Icons.event),
                      title: const Text('이벤트', style: TextStyle(fontWeight: FontWeight.bold)),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black),
                      selectedColor: Colors.red,
                      onTap: () {
                        showMsg(context, '이벤트', '이벤트');
                      },
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      leading: const Icon(Icons.point_of_sale),
                      title: const Text('포인트', style: TextStyle(fontWeight: FontWeight.bold)),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black),
                      onTap: () {
                        showMsg(context, '포인트', '포인트');
                      },
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      leading: const Icon(Icons.help_outline),
                      title: const Text('자주 묻는 질문(FAQ)', style: TextStyle(fontWeight: FontWeight.bold)),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black),
                      onTap: () {
                        showMsg(context, 'FAQ', 'FAQ');
                      },
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      leading: const Icon(Icons.notification_important),
                      title: const Text('공지사항', style: TextStyle(fontWeight: FontWeight.bold)),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black),
                      onTap: () {
                        showMsg(context, '공지사항', '공지사항');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }
}
