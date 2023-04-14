import 'dart:io';
import 'dart:typed_data';
import 'package:Aily/screens/login_screen.dart';
import 'package:Aily/utils/ShowDialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mysql1/mysql1.dart';
import 'package:Aily/proves/UserProvider.dart';
import 'package:provider/provider.dart';
import 'package:Aily/board/faq_screen.dart';
import 'package:Aily/board/notice_screen.dart';

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
  late File? profile;
  final storage = const FlutterSecureStorage();
  late String? _imageUrl;
  late bool _isLoading;

  Future<void> _getUser() async {
    final UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    username = userProvider.user.username;
    profile = userProvider.user.profile;
    setState(() {});
  }

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

  Future<void> logout() async {
    await storage.delete(key: 'id');
    await storage.delete(key: 'pw');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
    showMsg(context, '로그아웃', '로그아웃 되었습니다.');
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

  void _profileUpdate() async {
    final UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.updateProfile(_image);
    _getUser();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _profileUpdate();
      });
      await _uploadImage(_image!);
    }
  }

  Future<void> _uploadImage(File file) async {
    try {
      final formData = FormData.fromMap({
        'username': username,
        'file': await MultipartFile.fromFile(file.path, filename: 'image.png'),
      });
      final response = await Dio().post('http://211.201.93.173:8080/upload', data: formData);

      if (response.statusCode == 200) {
        setState(() {
          _imageUrl = response.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      //
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
                                //showMsg(context, '설정', '설정');
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
                                    child: profile == null
                                        ? Image.asset('assets/images/default.png', width: 80, height: 80)
                                        : Image.file(
                                      profile!,
                                      width: 80,
                                      height: 80,
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
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const FAQScreen()));
                      },
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      leading: const Icon(Icons.notification_important),
                      title: const Text('공지사항', style: TextStyle(fontWeight: FontWeight.bold)),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const NoticeScreen()));
                      },
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('로그아웃', style: TextStyle(fontWeight: FontWeight.bold)),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black),
                      onTap: () {
                        logout();
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
