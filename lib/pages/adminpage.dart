import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AdminPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AdminScreen();
  }
}

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with SingleTickerProviderStateMixin{

  double _height, _width;
  SharedPreferences prefs;
  bool _load = false;
  DocumentSnapshot snapshot;



  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: Colors.green[800], //Changing this will change the color of the TabBar
          accentColor: Colors.green[800]
      ),
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.green,
            bottom: TabBar(
              indicatorColor: Colors.white,
              tabs: [
                Tab(text: 'Customer'),
                Tab(text: 'Farmer'),
              ],
            ),
            title: Text('Admin'),
            actions: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.exit_to_app,
                  color: Colors.white,
                ),
                onPressed: (){
                  logout();
                },
              )
            ],
          ),
          body: TabBarView(
            children: [
              CustomerScreen(),
              FarmerScreen()
            ],
          ),
        ),
      ),
    );
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

  Widget CustomerScreen(){
    try {
      return StreamBuilder(
        stream: Firestore.instance.collection('users').where('role', isEqualTo:'Customer').snapshots(),
        builder: (BuildContext context,AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData)return CircularProgressIndicator();
          List data = snapshot.data.documents;
          var finalOrders = [];
          for(int i = 0;i < data.length;i++){
            List orders = data[i]['orders'];
            for(int j=0;j<orders.length;j++){
              var singleOrder = {
                'item': orders[j]['item'],
                'Quantity': orders[j]['Quantity'],
                'TimeStamp': orders[j]['TimeStamp'],
                'email': data[i].documentID,
                'firstname':data[i]['firstname'],
                'lastname':data[i]['lastname'],
                'contact':data[i]['contact'],
                'address':data[i]['address']
              };
              finalOrders.add(singleOrder);
            }
          }
          return new ListView(
            children: finalOrders.map((document) {
              return new Card(
                child:ListTile(
                  title: new Text('Item - '+document['item']),
                  subtitle: new Text('Quantity - '+document['Quantity']),
                  onTap: (){
                    customerDialog(document['item'], document['Quantity'], document['TimeStamp'], document['email'],document['firstname'], document['lastname'], document['contact'], document['address']);
                  },
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

  Widget FarmerScreen(){
    try {
      return new StreamBuilder(
        stream: Firestore.instance.collection('users').where('role', isEqualTo: 'Farmer').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return Center(
            child: CircularProgressIndicator(),
          );
          List data = snapshot.data.documents;
          var finalOrders = [];
          for(int i = 0;i < data.length;i++){
            List orders = data[i]['orders'];
            for(int j=0;j<orders.length;j++){
              var singleOrder = {
                'item': orders[j]['item'],
                'Quantity': orders[j]['Quantity'],
                'HarvestTime': orders[j]['HarvestTime'],
                'TimeStamp': orders[j]['TimeStamp'],
                'email': data[i].documentID,
                'firstname':data[i]['firstname'],
                'lastname':data[i]['lastname'],
                'contact':data[i]['contact'],
                'address':data[i]['address']
              };
              finalOrders.add(singleOrder);
            }
          }
          return new ListView(
            children:
            finalOrders.map((document) {
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
                  onTap: (){
                    farmerDialog(document['item'], document['Quantity'], document['HarvestTime'], document['TimeStamp'], document['email'], document['firstname'], document['lastname'], document['contact'], document['address']);
                  },
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

  customerDialog(String name, String quantity, Timestamp time, String email, String fname, String lname, String contact, String address) async{
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
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text('FirstName: ' +fname , style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,), textAlign: TextAlign.left,),
                      SizedBox(height: _height / 50.0),
                      Text('LastName: ' +lname, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,), textAlign: TextAlign.left,),
                      SizedBox(height: _height / 50.0),
                      Text('Contact: ' +contact, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,), textAlign: TextAlign.left,),
                      SizedBox(height: _height / 50.0),
                      Text('Address: ' +address, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,), textAlign: TextAlign.left,),
                      SizedBox(height: _height / 40.0),
                      button(name, quantity, time, email)
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }


  Widget button(name, quantity, time, email) {
    return !_load ? RaisedButton(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      onPressed: () {
        deleteCustomer(name, quantity, time, email);
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
        child: Text('Mark As Completed', style: TextStyle(fontSize: 15,color: Colors.white) ),
      ),
    ) : Center(
      child: CircularProgressIndicator(),
    );
  }

  Future <void> deleteCustomer(String itemName, String quantity, Timestamp time, String email)async {
    try {
      await Firestore.instance.collection('users').document(email).updateData({
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

  farmerDialog(String name, String quantity, String harvest, Timestamp time, String email, String fname, String lname, String contact, String address) async{
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
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text('FirstName: ' +fname, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,), textAlign: TextAlign.left,),
                      SizedBox(height: _height / 50.0),
                      Text('LastName: ' +lname, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,), textAlign: TextAlign.left,),
                      SizedBox(height: _height / 50.0),
                      Text('Contact: ' +contact, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,), textAlign: TextAlign.left,),
                      SizedBox(height: _height / 50.0),
                      Text('Address: ' +address, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,), textAlign: TextAlign.left,),
                      SizedBox(height: _height / 40.0),
                      button1(name, quantity, time, harvest, email)
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget button1(name, quantity, time, harvest, email) {
    return !_load ? RaisedButton(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      onPressed: () {
        deleteFarmer(name, quantity, harvest, time, email);
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
        child: Text('Mark As Completed', style: TextStyle(fontSize: 15,color: Colors.white) ),
      ),
    ) : Center(
      child: CircularProgressIndicator(),
    );
  }

  Future <void> deleteFarmer(String itemName, String quantity, String harvest, Timestamp time, String email)async {
    try {
      await Firestore.instance.collection('users').document(email).updateData({
        'orders': FieldValue.arrayRemove([
          {
            'item': itemName,
            'Quantity': quantity,
            'HarvestTime': harvest,
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

}