import 'dart:io';
import 'package:Aily/screens/login_screen.dart';
import 'package:Aily/utils/ShowDialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Aily/proves/testUserProvider.dart';
import 'package:provider/provider.dart';
import 'package:Aily/board/faq_screen.dart';
import 'package:Aily/board/notice_screen.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class Account_screen extends StatefulWidget {
  const Account_screen({Key? key}) : super(key: key);

  @override
  _Account_screenState createState() => _Account_screenState();
}

class _Account_screenState extends State<Account_screen> {
  late File? _image;
  String? username;
  File? profile;
  final storage = const FlutterSecureStorage();

  Future<void> _getUser() async {
    final UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    setState(() {
      username = userProvider.user.nickname;
      profile = userProvider.user.image;
    });
  }

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void logout(BuildContext context) async {
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

  void _profileUpdate(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.updateImage(_image!);
    profile = userProvider.user.image;
    final cacheManager = DefaultCacheManager();
    await cacheManager.removeFile(profile!.path);
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      _profileUpdate(context);
      await _uploadImage(_image!);
    }
  }

  Future<void> _uploadImage(File file) async {
    try {
      final formData = FormData.fromMap({
        'username': username,
        'file': await MultipartFile.fromFile(file.path, filename: 'image.png'),
      });
      final response = await Dio().post('http://211.201.93.173:8083/api/image', data: formData);

      if (response.statusCode == 200) {
        //
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
      body: AccountWidget(context),
    );
  }
  Widget AccountWidget(BuildContext context) {
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
                    Consumer<UserProvider>(
                      builder: (context, UserProvider, _) => SizedBox(
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
                                  child: ClipOval(
                                    child: Image.file(
                                      profile!,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                title: Text(
                                    username!,
                                    style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold
                                    )
                                ),
                                trailing: const Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.black
                                ),
                                onTap: () {
                                  _pickImage(context, ImageSource.gallery);
                                  //showMsg(context, '프로필', '프로필');
                                },
                              ),
                            ),
                          ],
                        ),
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
                        logout(context);
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