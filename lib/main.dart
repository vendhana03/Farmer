import 'package:farmer/pages/adminpage.dart';
import 'package:farmer/pages/forgotpassword.dart';
import 'package:farmer/pages/home.dart';
import 'package:farmer/pages/login.dart';
import 'package:farmer/pages/signup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';



void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  Widget _defaulthome;

   SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = await prefs.getString('email');
    String role = await prefs.getString('role');
    print(role);
    if(role == 'admin'){
      _defaulthome = AdminPage();
    }
    else if (userId != null) {
    _defaulthome = new Home();
  }else{
    _defaulthome = new LoginPage();
  }

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_){
    runApp(MyApp(_defaulthome));
  });

}

class MyApp extends StatelessWidget {
  final _defaulthome ;

  MyApp(this._defaulthome);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: 'Farmer',
      theme: ThemeData(primaryColor: Colors.green),
      debugShowCheckedModeBanner: false,
      home: _defaulthome,
      routes: <String, WidgetBuilder>{
        'home': (BuildContext context) => new Home(),
        'login': (BuildContext context) => new LoginPage(),
        'forgotpassword': (BuildContext context) => ForgotPassword(),
        'signup':(BuildContext context) => SignUp(),
        'adminpage' :(BuildContext context) => AdminPage()
      },
    );
  }

}