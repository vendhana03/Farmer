import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SignupPage(),
    );
  }
}
class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  double _height, _width;
  String _email = '',
      _password = '',
      _fname = '',
      _lname = '',
      _phone = '',
      _address = '';
  GlobalKey<FormState> _key = GlobalKey();
  bool _showPassword = true,
      _load = false;
  List<String> _role = ['Customer', 'Farmer'];
  String _selectedrole;

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('SignUp'),
      ),
      body: Container(
        height: _height,
        width: _width,
        padding: EdgeInsets.only(bottom: 5),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              image(),
              signupText(),
              form(),
              SizedBox(height: _height / 12),
              button(),
            ],
          ),
        ),
      ),
    );
  }

  Widget image() {
    return Container(
      margin: EdgeInsets.only(top: _height / 15.0),
      height: 100.0,
      width: 100.0,
      decoration: new BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: new Image.asset('images/login.png'),
    );
  }

  Widget signupText() {
    return Container(
      margin: EdgeInsets.only(left: _width / 15.0),
      child: Row(
        children: <Widget>[
          Text(
            "Create Account",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
        ],
      ),
    );
  }


  Widget form() {
    return Container(
      margin: EdgeInsets.only(
          left: _width / 12.0,
          right: _width / 12.0,
          top: _height / 15.0),
      child: Form(
        key: _key,
        child: Column(
          children: <Widget>[
            firstname(),
            SizedBox(height: _height / 40.0),
            lastname(),
            SizedBox(height: _height / 40.0),
            emailBox(),
            SizedBox(height: _height / 40.0),
            contact(),
            SizedBox(height: _height / 40.0),
            address(),
            SizedBox(height: _height / 40.0),
            usertype(),
            SizedBox(height: _height / 40.0),
            passwordBox(),
          ],
        ),
      ),
    );
  }

  Widget emailBox() {
    return Material(
      borderRadius: BorderRadius.circular(30.0),
      elevation: 10,
      child: TextFormField(
        onSaved: (input) => _email = input,
        keyboardType: TextInputType.emailAddress,
        cursorColor: Colors.green,
        obscureText: false,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.email, color: Colors.green, size: 20),
          hintText: "Email ID",
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget passwordBox() {
    return Material(
      borderRadius: BorderRadius.circular(30.0),
      elevation: 10,
      child: TextFormField(
        onSaved: (input) => _password = input,
        keyboardType: TextInputType.visiblePassword,
        cursorColor: Colors.green,
        obscureText: _showPassword,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.lock, color: Colors.green, size: 20),
          suffixIcon: IconButton(
            icon: Icon(
              Icons.remove_red_eye,
              color: this._showPassword ? Colors.grey : Colors.green,
            ),
            onPressed: () {
              setState(() => this._showPassword = !this._showPassword);
            },
          ),
          hintText: "New Password",
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none
          ),
        ),
      ),
    );
  }

  Widget firstname(){
    return Material(
        borderRadius: BorderRadius.circular(30.0),
        elevation: 10,
    child: TextFormField(
      onSaved: (input) => _fname = input,
      keyboardType: TextInputType.text,
      cursorColor: Colors.green,
      obscureText: false,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.person, color: Colors.green, size: 20),
        hintText: "First Name",
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none),
      ),
    ),
    );
  }

  Widget lastname() {
    return Material(
      borderRadius: BorderRadius.circular(30.0),
      elevation: 10,
      child: TextFormField(
        onSaved: (input) => _lname = input,
        keyboardType: TextInputType.text,
        cursorColor: Colors.green,
        obscureText: false,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.person, color: Colors.green, size: 20),
          hintText: "Last Name",
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none),
        ),
      ),
    );
  }

    Widget contact() {
      return Material(
        borderRadius: BorderRadius.circular(30.0),
        elevation: 10,
        child: TextFormField(
          onSaved: (input) => _phone = input,
          keyboardType: TextInputType.number,
          cursorColor: Colors.green,
          obscureText: false,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.phone, color: Colors.green, size: 20),
            hintText: "Phone Number",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide.none),
          ),
        ),
      );
    }

  Widget address() {
    return Material(
      borderRadius: BorderRadius.circular(30.0),
      elevation: 10,
      child: TextFormField(
        onSaved: (input) => _address = input,
        keyboardType: TextInputType.text,
        cursorColor: Colors.green,
        obscureText: false,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.home, color: Colors.green, size: 20),
          hintText: "Address",
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget button() {
    return !_load ? RaisedButton(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      onPressed: () {
        RegExp regExp = new RegExp(
            r'^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$');
        RegExp regPh = new  RegExp(
            r'(^(?:[+0]9)?[0-9]{10,12}$)');
        final formstate = _key.currentState;
        formstate.save();
        if (_email == null || _email.isEmpty) {
          Scaffold.of(context).showSnackBar(
              SnackBar(content: Text('Email Cannot be empty')));
        } else if (_password == null || _password.length < 6) {
          Scaffold.of(context).showSnackBar(SnackBar(
              content: Text('Password needs to be atleast six characters')));
        } else if (!regExp.hasMatch(_email)) {
          Scaffold.of(context).showSnackBar(
              SnackBar(content: Text('Enter a Valid Email')));
        }else if (_fname == null || _fname.isEmpty){
          Scaffold.of(context).showSnackBar(
              SnackBar(content: Text('First Name Cannot be empty')));
        }else if (_lname == null || _lname.isEmpty){
          Scaffold.of(context).showSnackBar(
              SnackBar(content: Text('Last Name Cannot be empty')));
        }else if (_phone == null || _phone.isEmpty){
          Scaffold.of(context).showSnackBar(
              SnackBar(content: Text('Phone Number Cannot be empty')));
        }else if(!regPh.hasMatch(_phone)) {
          Scaffold.of(context).showSnackBar(
              SnackBar(content: Text('Enter a Valid Phone Number')));
        }else if (_address == null || _address.isEmpty) {
          Scaffold.of(context).showSnackBar(
              SnackBar(content: Text('Address Cannot be empty')));
        } else {
          setState(() {
            _load = true;
          });
          SignUp();
        }
      },
      textColor: Colors.white,
      padding: EdgeInsets.all(0.0),
      child: Container(
        alignment: Alignment.center,
        width: _width / 2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
          gradient: LinearGradient(
            colors: <Color>[Colors.green, Colors.lightGreen],
          ),
        ),
        padding: const EdgeInsets.all(12.0),
        child: Text('SIGN UP', style: TextStyle(fontSize: 15)),
      ),
    ) : Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget usertype(){
    return FormField(
        builder: (FormFieldState state) {
          return DropdownButtonHideUnderline(
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                new InputDecorator(
                  decoration: InputDecoration(
                    filled: false,
                    prefixIcon: Icon(
                        Icons.face, color: Colors.green, size: 20),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none),
                  ),
                  isEmpty: _selectedrole == null,
                   child: DropdownButton<String>(
                     value: _selectedrole,
                     hint: Text('Please Select Your Role'),
                     underline: Container(),
                     icon: Icon(Icons.arrow_drop_down, color: Colors.green,),
                     iconSize: 25.0, // can be changed, default: 24.0
                     iconEnabledColor: Colors.green,
                     items:_role.map<DropdownMenuItem<String>>((String value) {
                       return DropdownMenuItem<String>(
                         value: value,
                         child: Text("   $value   "),
                       );
                     }).toList(),
                     onChanged: (String value) {
                       setState(() {
                         _selectedrole = value;
                       });
                       },
                   ),
                ),
              ],
            ),
          );
        },
    );
  }

  Future<void> SignUp() async{
    try{
      AuthResult result = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _email, password: _password);
      await Firestore.instance.collection('users').document(_email).setData({'firstname':_fname,'lastname':_lname,'contact':_phone,'address':_address,'role':_selectedrole, 'orders':[],});
      setState((){_load = false;});
      Navigator.of(context).pushReplacementNamed('login');
    }catch(e){
      setState((){_load = false;});
      print(e.message);
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }

  }

}
