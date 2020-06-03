import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'addPostCustomer.dart';
import 'addpostfarmer.dart';

class Home extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _height, _width;
  SharedPreferences prefs;
  bool _load = false;
  String _email, _role;
  GlobalKey<FormState> _key = GlobalKey();
  String newquantity='', newharvest='';



  @override
  void initState(){
    super.initState();
    try {
      SharedPreferences.getInstance().then((sharedPrefs) {
        setState(() {
          prefs = sharedPrefs;
          _email = prefs.getString('email');
          _role = prefs.getString('role');
        });
      });
    } catch (e) {
      print(e.message);
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }


  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.exit_to_app,
              color: Colors.white,
            ),
            onPressed: (){
              setState((){_load = true;});
              logout();
            },
          )
        ],
      ),
      body:  !_load ? role(): Center(
          child: CircularProgressIndicator()
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        elevation: 50,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        onPressed: () {
          checkRole();
        },
      ),
    );
  }

  Widget role() {
    switch (_role) {
      case 'Customer':
        return listViewCustomers();
        break;
      case 'Farmer':
        return listViewFarmers();
        break;
    }
  }

  Widget checkRole(){
    if(_role == 'Farmer')
    {
      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => AddPostFarmer()));
    }
    else if(_role == 'Customer')
    {
      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => AddPostCustomer()));
    }
  }

  void logout() async {
    try{
      await FirebaseAuth.instance.signOut();
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('email', null);
      prefs.setString('role', null);
      setState((){_load = false;});
      Navigator.of(context).pushReplacementNamed('login');
    }catch(e){
      setState((){_load = false;});
      print(e.message);
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Widget listViewCustomers() {
    try {
      return new StreamBuilder(
        stream: Firestore.instance.collection('users').where(FieldPath.documentId, isEqualTo: _email).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return Center(
            child: CircularProgressIndicator(),
          );
          List data = snapshot.data.documents[0]['orders'];
          return new ListView(
            children: data.map((document) {
              return new Card(
                child:ListTile(
                  title: new Text('Item - '+document['item']),
                  subtitle: new Text('Quantity - '+document['Quantity']),
                  trailing: Wrap(spacing: 12,
                    children: <Widget>[
                      new IconButton(icon: Icon(Icons.edit), color: Colors.green,
                        onPressed: (){
                          customerDialog(document['item'],document['Quantity'],document['TimeStamp']);
                        },),
                      new IconButton(icon: Icon(Icons.delete),color: Colors.green,
                        onPressed: (){
                          deleteCustomer(document['item'],document['Quantity'],document['TimeStamp']);
                        },),
                    ],),
                ),
              );
            }).toList(),
          );
        },
      );
    } catch (e) {
      print(e.message);
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      return Center(child: Text(e.message));
    }
  }

  Widget listViewFarmers() {
    try {
      return new StreamBuilder(
        stream: Firestore.instance.collection('users').where(FieldPath.documentId, isEqualTo: _email).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return Center(
            child: CircularProgressIndicator(),
          );
          List data1 = snapshot.data.documents[0]['orders'];
          return new ListView(
            children:
            data1.map((document) {
              return new Card(
                child:ListTile(
                  title: new Text('Item - '+document['item']),
                  subtitle:new Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Text('Quantity - '+document['Quantity'], textAlign: TextAlign.left),
                      new Text('HarvestTime - '+document['HarvestTime'], textAlign: TextAlign.left,)
                    ],
                  ),
                  trailing:  Wrap(spacing: 12,
                    children: <Widget>[
                      new IconButton(icon: Icon(Icons.edit), color: Colors.green,
                        onPressed: (){
                          farmerDialog(document['item'],document['Quantity'],document['HarvestTime'],document['TimeStamp']);
                        },),
                      new IconButton(icon: Icon(Icons.delete),color: Colors.green,
                        onPressed: (){
                          deleteFarmer(document['item'],document['Quantity'],document['HarvestTime'],document['TimeStamp']);
                        },),
                    ],),
                ),
              );
            }).toList(),
          );
        },
      );
    } catch (e) {
      print(e.message);
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      return Center(child: Text(e.message));
    }
  }

  Future <void> deleteCustomer(String itemName, String quantity, Timestamp time)async {
    try {
      await Firestore.instance.collection('users').document(_email).updateData({
        'orders': FieldValue.arrayRemove([
          {
            'item': itemName,
            'Quantity': quantity,
            'TimeStamp': time
          }
        ])
      });
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text('Deleted successfully..')));
    }catch(e){
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future <void> deleteFarmer(String itemName, String quantity,String harvest, Timestamp time)async {
    try {
      await Firestore.instance.collection('users').document(_email).updateData({
        'orders':FieldValue.arrayRemove([
          {
            'item': itemName,
            'Quantity': quantity,
            'HarvestTime': harvest ,
            'TimeStamp': time
          }
        ])
      });
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text('Deleted successfully..')));
    }catch(e){
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }


  customerDialog(String name, String quantity, Timestamp time) async{
    newquantity = quantity;
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return Center(
            child: AlertDialog(
              content: Stack(
                overflow: Overflow.visible,
                children: <Widget>[
                  Positioned(
                    right: -40.0,
                    top: -40.0,
                    child: InkResponse(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: CircleAvatar(
                        child: Icon(Icons.close, color: Colors.white,),
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
                  Form(
                    key: _key,
                    child:Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        itemQuantity(),
                        SizedBox(height: _height / 40.0),
                        button(name, quantity, time)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  farmerDialog(String name, String quantity, String harvest, Timestamp time) async{
    newquantity = quantity;
    newharvest = harvest;
    setState(() {
      valHarvest.text = harvest;
    });
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return Center(
            child: AlertDialog(
              content: Stack(
                overflow: Overflow.visible,
                children: <Widget>[
                  Positioned(
                    right: -40.0,
                    top: -40.0,
                    child: InkResponse(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: CircleAvatar(
                        child: Icon(Icons.close, color: Colors.white,),
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
                  Form(
                    key: _key,
                    child:Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        itemQuantity(),
                        SizedBox(height: _height / 40.0),
                        harvestTime(),
                        SizedBox(height: _height / 40.0),
                        button1(name, quantity, harvest, time)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  TextEditingController valHarvest = new TextEditingController();
  int yr = DateTime.now().year;

  Widget harvestTime(){
    return Material(
      borderRadius: BorderRadius.circular(30.0),
      elevation: 10,
      child:TextFormField(
          keyboardType: TextInputType.datetime,
          readOnly: true,
          controller: valHarvest,
          cursorColor: Colors.green,
          obscureText: false,
          decoration: InputDecoration(
            suffixIcon: new Icon(Icons.calendar_today, color: Colors.green, size: 20),
            hintText: "Harvest Time",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide.none),
          ),
          onTap: ()async{
            final datePick= await showDatePicker(
              context: context,
              initialDate: new DateTime.now(),
              firstDate: new DateTime(yr),
              lastDate: new DateTime(yr+2),
              builder: (BuildContext context, Widget child) {
                return Theme(
                  data: ThemeData.light().copyWith(
//                    primarySwatch: buttonTextColor,//OK/Cancel button text color
                    primaryColor: const Color(0xFF4CAF50),//Head background
                    accentColor: const Color(0xFF4CAF50),//selection color
                    dialogBackgroundColor: Colors.white,//Background color
                    colorScheme: ColorScheme.light(primary: const Color(0xFF4CAF50)),
                    buttonTheme: ButtonThemeData(
                        textTheme: ButtonTextTheme.primary
                    ),
                  ),
                  child: child,
                );
              },
            );
            if(datePick!=null){
              setState(() {
                newharvest = "${datePick.month}/${datePick.day}/${datePick.year}";
                valHarvest.text = newharvest;
                print(newharvest);
              });
            }
          }
      ),
    );
  }

  Widget itemQuantity() {
    return Material(
      borderRadius: BorderRadius.circular(30.0),
      elevation: 10,
      child: TextFormField(
        initialValue: newquantity,
        onSaved: (input) => newquantity = input,
        keyboardType: TextInputType.text,
        cursorColor: Colors.green,
        obscureText: false,
        decoration: InputDecoration(
          hintText: "Quantity in kg/litre",
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget button(name, quantity, time) {
    return !_load ? RaisedButton(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      onPressed: () {
        _key.currentState.save();
        updateCustomer(name, quantity, time);
        Navigator.of(context).pop();
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
        child: Text('Submit', style: TextStyle(fontSize: 15,color: Colors.white) ),
      ),
    ) : Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget button1(name, quantity, harvest, time) {
    return !_load ? RaisedButton(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      onPressed: () {
        _key.currentState.save();
        updateFarmer(name, quantity, harvest, time);
        Navigator.of(context).pop();
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
        child: Text('Submit', style: TextStyle(fontSize: 15,color: Colors.white) ),
      ),
    ) : Center(
      child: CircularProgressIndicator(),
    );
  }


  Future<void> updateCustomer(String name, String quantity, Timestamp time) async {
    try {
      await Firestore.instance.collection('users').document(_email).updateData({'orders': FieldValue.arrayRemove([{'item' :name , 'Quantity' : quantity  ,'TimeStamp' : time}])});
      await Firestore.instance.collection('users').document(_email).updateData({'orders': FieldValue.arrayUnion([{'item' :name , 'Quantity' : newquantity  ,'TimeStamp' : DateTime.now()}])});
    }catch(e){
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future <void> updateFarmer(String name, String quantity, String harvest, Timestamp time) async{
    try {
      await Firestore.instance.collection('users').document(_email).updateData({'orders': FieldValue.arrayRemove([{'item' :name , 'Quantity' : quantity  ,'HarvestTime': harvest ,'TimeStamp' : time}])});
      print(newquantity);
      print(newharvest);
      await Firestore.instance.collection('users').document(_email).updateData({'orders': FieldValue.arrayUnion([{'item' :name , 'Quantity' : newquantity  , 'HarvestTime': newharvest, 'TimeStamp' : DateTime.now()}])});
    }catch(e){
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

}