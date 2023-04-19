import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'manager_screen.dart';
import 'package:Aily/utils/ShowDialog.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mysql1/mysql1.dart';
import 'package:Aily/class/User.dart';
//import 'package:Aily/proves/UserProvider.dart';
import 'package:Aily/proves/testUserProvider.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../widgets/Navigator.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:Aily/class/User.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController _idctrl;
  late TextEditingController _passwordctrl;

  late TextEditingController _signidctrl;
  late TextEditingController _signpwctrl;
  late TextEditingController _signpwctrl2;
  late TextEditingController _signphonectrl;
  late TextEditingController _signnicknamectrl;

  Color myColor = const Color(0xFFF8B195);
  late Uint8List imgData;
  final storage = const FlutterSecureStorage();
  late int point, phonenumber;
  late String nickname, image;
  late File? profile;
  late DateTime _selectedDate;
  String? _selectedGender;
  final List<String> _genders = ['남', '여'];
  String? _birth;
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  int _selectedDay = DateTime.now().day;

  @override
  void initState() {
    super.initState();
    _idctrl = TextEditingController();
    _passwordctrl = TextEditingController();

    _signidctrl = TextEditingController();
    _signpwctrl = TextEditingController();
    _signpwctrl2 = TextEditingController();
    _signphonectrl = TextEditingController();
    _signnicknamectrl = TextEditingController();
    _selectedDate = DateTime(_selectedYear, _selectedMonth, _selectedDay);
    _selectedGender = '남';
    //tryAutoLogin();
  }

  @override
  void dispose() {
    _idctrl.dispose();
    _passwordctrl.dispose();
    _signidctrl.dispose();
    _signpwctrl.dispose();
    _signpwctrl2.dispose();
    _signphonectrl.dispose();
    _signnicknamectrl.dispose();
    super.dispose();
  }

  Future<void> downloadImageFromServer(String nickname) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/profile.png';
      final profileFile = File(imagePath);

      try {
        final response = await http.get(Uri.parse(image));

        if (await profileFile.exists()) {
          await profileFile.delete();
        }
        await profileFile.writeAsBytes(response.bodyBytes, mode: FileMode.write);
        setState(() {
          profile = profileFile;
        });
        final UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.updateNickname(nickname);
        userProvider.updatePoint(point);
        userProvider.updateImage(profile!);
        userProvider.updatePhoneNumber(phonenumber);
      } catch (e) {
        //
      }
      //현재 페이지를 제거 후 페이지 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NavigatorScreen()),
      );
    } catch (e) {
      //
    }
  }

  Future<void> saveLoginInfo(String id, String pw) async {
    await storage.write(key: 'id', value: id);
    await storage.write(key: 'pw', value: pw);
  }

  Future<void> tryAutoLogin() async {
    final id = await storage.read(key: 'id');
    final pw = await storage.read(key: 'pw');
    try {
      http.Response response = await loginUser(id!, pw!);
      if (response.statusCode == 200){
        //로그인 성공
        var jsonResponse = jsonDecode(response.body);
        image = jsonResponse[0]['image'];
        if (id == 'admin'){
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const ManagerScreen()),
                (route) => false,
          );
        }else{
          showLoadingDialog(context);
          downloadImageFromServer(id);
        }
      }
    } catch (e) {
      showMsg(context, "로그인", "아이디 또는 비밀번호가 올바르지 않습니다.$e");
    }
  }

  Future<http.Response> loginUser(String id, String password) async {
    final response = await http.post(
        Uri.parse('http://211.201.93.173:8081/api/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'id': id,
          'password': password,
        })
    );
    return response;
  }

  Future<void> login() async {
    final String id = _idctrl.text.trim();
    final String pw = _passwordctrl.text.trim();

    var bytes = utf8.encode(pw); // 문자열을 바이트 배열로 변환
    var md5Result = md5.convert(bytes); // MD5 해시 값 생성
    String md5Password = md5Result.toString();
    // 로그인 처리 로직 구현
    if (id.isEmpty || pw.isEmpty) {
      showMsg(context, "로그인", "아이디 또는 비밀번호를 입력해주세요.");
    } else {
      try {
        http.Response response = await loginUser(id, md5Password);
        if (response.statusCode == 200){
          //로그인 성공
          var jsonResponse = jsonDecode(response.body);
          nickname = jsonResponse[0]['nickname'];
          point = jsonResponse[0]['point'];
          image = jsonResponse[0]['profile'];
          phonenumber = jsonResponse[0]['User_phonenumber'];
          saveLoginInfo(id, md5Password);
          if (id == 'admin'){
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const ManagerScreen()),
                  (route) => false,
            );
          }else{
            showLoadingDialog(context);
            downloadImageFromServer(nickname);
          }
        }
      } catch (e) {
        showMsg(context, "로그인", "아이디 또는 비밀번호가 올바르지 않습니다.");
      }
    }
  }

  Future<http.Response> signUser(String phone, String id, password, nickname, birth) async {
    final Map<String, dynamic> data = {
      "phonenumber": phone,
      "id": id,
      "password": password,
      "birth": birth,
      "nickname": nickname,
      "profile": "http://211.201.93.173:8083/static/images/default/image.png"
    };

    final response = await http.post(
      Uri.parse('http://211.201.93.173:8080/api/sign'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return response;
  }

  Future<void> signup(UserProvider userProvider) async {
    final String id = _signidctrl.text.trim();
    final String pw = _signpwctrl.text.trim();
    final String confirmPw = _signpwctrl2.text.trim();
    final String phone = _signphonectrl.text.trim();
    final String nickname = _signnicknamectrl.text.trim();

    var bytes = utf8.encode(pw); // 문자열을 바이트 배열로 변환
    var md5Result = md5.convert(bytes); // MD5 해시 값 생성
    String md5Password = md5Result.toString();

    // String username = userProvider.user.username;
    // final User user = User.withDefaultProfile(username: username);
    // userProvider.updateUser(user);

    // 회원가입 처리 로직 구현
    if (id.contains(' ') || pw.contains(' ')) {
      showMsg(context, "회원가입", "아이디 또는 비밀번호에 공백이 포함되어 있습니다.");
    }
    else if (id.isEmpty || pw.isEmpty || confirmPw.isEmpty) {
      showMsg(context, "회원가입", "아이디 또는 비밀번호를 입력해주세요.");
    } else {
      if (pw == confirmPw) {
        try{
          http.Response response = await signUser(phone, id, md5Password, nickname, _birth);
          final responsebody = json.decode(utf8.decode(response.bodyBytes));
          final error = responsebody['error'];
          if (error == '중복된 닉네임입니다.'){
            showMsg(context, "회원가입", "중복된 닉네임입니다.");
          }else if (error == '중복된 전화번호입니다.'){
            showMsg(context, "회원가입", "중복된 전화번호입니다.");
          }
        } catch (e) {
          _dismissModalBottomSheet();
          showMsg(context, "회원가입", "회원가입 완료");
        }
      } else {
        showMsg(context, "회원가입", "비밀번호가 일치하지 않습니다.");
      }
    }
  }

  void _dismissModalBottomSheet() {
    _signidctrl.clear();
    _signpwctrl.clear();
    _signpwctrl2.clear();
    _signphonectrl.clear();
    _signnicknamectrl.clear();
    Navigator.of(context).pop();
  }

  void _updateSelectedYear(int? year) {
    setState(() {
      _selectedYear = year ?? DateTime.now().year;
      _selectedDate = DateTime(_selectedYear, _selectedMonth, _selectedDay);

      // 해당 월의 마지막 일자를 계산하여 일자수를 업데이트합니다.
      int daysInMonth = DateTime(_selectedYear, _selectedMonth + 1, 0).day;
      if (_selectedDay > daysInMonth) {
        _selectedDay = daysInMonth;
        _selectedDate = DateTime(_selectedYear, _selectedMonth, _selectedDay);
        _updateBirth();
      }
    });
  }

  void _updateSelectedMonth(int? month) {
    setState(() {
      _selectedMonth = month ?? DateTime.now().month;
      _selectedDate = DateTime(_selectedYear, _selectedMonth, _selectedDay);

      // 해당 월의 마지막 일자를 계산하여 일자수를 업데이트합니다.
      int daysInMonth = DateTime(_selectedYear, _selectedMonth + 1, 0).day;
      if (_selectedDay > daysInMonth) {
        _selectedDay = daysInMonth;
        _selectedDate = DateTime(_selectedYear, _selectedMonth, _selectedDay);
        _updateBirth();
      }
    });
  }

  void _updateSelectedDay(int? day) {
    setState(() {
      _selectedDay = day ?? DateTime.now().day;
      _selectedDate = DateTime(_selectedYear, _selectedMonth, _selectedDay);
      _updateBirth();
    });
  }

  void _updateSelectedGender(String? gender) {
    setState(() {
      _selectedGender = gender!;
    });
  }

  void _updateBirth() {
    if (_selectedYear == null || _selectedMonth == null || _selectedDay == null) {
      _birth = null;
    } else {
      _birth = '${_selectedYear!}-${_selectedMonth!.toString().padLeft(2, '0')}-${_selectedDay!.toString().padLeft(2, '0')}';
    }
  }

  Widget buildTextFormField(String hintText, TextEditingController controller, TextInputType keyboardType, bool obscure) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        border: const UnderlineInputBorder(),
      ),
      obscureText: obscure,
    );
  }

  Widget buildDropdownButtonFormField<T>(
      List<DropdownMenuItem<T>> items,
      T value,
      Function(T?) onChanged,
      InputDecoration decoration,
      double width,
      double height
      ) {
    return SizedBox(
      width: width,
      height: height,
      child: DropdownButtonFormField<T>(
        decoration: decoration,
        value: value,
        items: items,
        onChanged: onChanged,
        menuMaxHeight: 250,
      ),
    );
  }

  Future<void> signSheet () async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery
                  .of(context)
                  .viewInsets
                  .bottom),
          child: SingleChildScrollView(
            child: Container(
              height: MediaQuery
                  .of(context)
                  .size
                  .height * 0.7,
              padding: const EdgeInsets.symmetric(
                  horizontal: 20.0, vertical: 40.0),
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment
                      .stretch,
                  children: [
                    const Text(
                      '회원가입',
                      style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10.0),
                    buildTextFormField('아이디 입력', _signidctrl, TextInputType.text, false),
                    buildTextFormField('비밀번호 입력', _signpwctrl, TextInputType.visiblePassword, true),
                    buildTextFormField('비밀번호 확인', _signpwctrl2, TextInputType.visiblePassword, true),
                    const SizedBox(height: 20.0),
                    const Text('생년월일'),
                    Row(
                      children: [
                        SizedBox(
                          width: 70,
                          height: 50,
                          child: Expanded(
                            child: buildDropdownButtonFormField<int>(
                                List.generate(
                                  100,
                                      (index) => DropdownMenuItem<int>(
                                    value: DateTime.now().year - index,
                                    child: Text(
                                      '${DateTime.now().year - index}',
                                    ),
                                  ),
                                ),
                                _selectedYear,
                                _updateSelectedYear,
                                const InputDecoration(
                                  border: UnderlineInputBorder(),
                                ),
                                70,
                                50
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        SizedBox(
                          width: 70,
                          height: 50,
                          child: Expanded(
                            child: buildDropdownButtonFormField<int>(
                                List.generate(
                                  12,
                                      (index) => DropdownMenuItem<int>(
                                    value: index + 1,
                                    child: Text(
                                      '${index + 1}월',
                                    ),
                                  ),
                                ),
                                _selectedMonth,
                                _updateSelectedMonth,
                                const InputDecoration(
                                  border: UnderlineInputBorder(),
                                ),
                                70,
                                50
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        SizedBox(
                          width: 70,
                          height: 50,
                          child: Expanded(
                            child: buildDropdownButtonFormField<int>(
                                List.generate(
                                  31,
                                      (index) => DropdownMenuItem<int>(
                                    value: index + 1,
                                    child: Text(
                                      '${index + 1}일',
                                    ),
                                  ),
                                ),
                                _selectedDay,
                                _updateSelectedDay,
                                const InputDecoration(
                                  border: UnderlineInputBorder(),
                                ),
                                70,
                                50
                            ),
                          ),
                        ),
                        const SizedBox(width: 50.0),
                        SizedBox(
                          width: 70,
                          height: 50,
                          child: buildDropdownButtonFormField<String>(
                            _genders.map((gender) {
                              return DropdownMenuItem<String>(
                                value: gender,
                                child: Row(
                                  children: [
                                    gender == '남'
                                        ? const Icon(Icons.man, color: Colors.blue)
                                        : const Icon(Icons.woman, color: Colors.red),
                                    Text(gender)
                                  ],
                                ),
                              );
                            }).toList(),
                            _selectedGender!,
                            _updateSelectedGender,
                            const InputDecoration(
                              border: UnderlineInputBorder(),
                            ),
                            70,
                            50,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                    buildTextFormField('이름', _signnicknamectrl, TextInputType.text, false),
                    buildTextFormField('전화번호 입력', _signphonectrl, TextInputType.phone, false),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () async {
                        final id = _signidctrl.text.trim();
                        UserProvider userProvider = UserProvider();
                        // User newUser = User.withDefaultProfile(username: id);
                        // userProvider.updateUser(newUser);

                        await signup(userProvider);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 248, 177, 149),
                        padding: const EdgeInsets.symmetric(vertical: 13.0, horizontal: 140.0),
                      ),
                      child: const Text('확 인'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 60.0),
        child: Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 7, bottom: 10.0),
                      child: Text(
                        "Ai Recycling",
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Waiting for the Sunrise',
                          fontWeight: FontWeight.bold,
                          color: myColor,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        "AILY",
                        style: TextStyle(
                          fontSize: 50,
                          fontFamily: 'Waiting for the Sunrise',
                          fontWeight: FontWeight.bold,
                          color: myColor,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        width: 200.0,
                        height: 200.0,
                      ),
                      const SizedBox(height: 32.0),
                      TextField(
                        controller: _idctrl,
                        decoration: const InputDecoration(
                          hintText: '아이디 입력',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      TextField(
                        controller: _passwordctrl,
                        decoration: const InputDecoration(
                          hintText: '비밀번호 입력',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 32.0),
                      ElevatedButton(
                        onPressed: () {
                          signSheet();
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: myColor,
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 13.0, horizontal: 138.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            side: BorderSide(
                              color: myColor, // 원하는 색상으로 변경
                              width: 2.0, // 테두리 두께
                            ),
                          ),
                        ),
                        child: Text('회원가입', style: TextStyle(color: myColor)),
                      ),
                      const SizedBox(height: 13.0),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              login();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: myColor,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 13.0, horizontal: 144.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                            child: const Text('로그인'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}