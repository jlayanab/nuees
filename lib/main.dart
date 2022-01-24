import 'dart:io';
import 'package:uees/view/listItems.dart';
import 'package:uees/view/login.dart';
import 'package:uees/view/generate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:uees/Controllers/databasehelpers.dart';
import 'package:uees/Controllers/program.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Registro UEES",
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
      theme: ThemeData(
          primaryColor: Color.fromRGBO(62, 15, 31, 1),
          accentColor: Colors.white70),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  DataBaseHelper databasehelper = new DataBaseHelper();
  String usuario, newPath, albumName = 'Media';
  SharedPreferences sharedPreferences;
  File imagepicture, image;
  Program program = new Program();

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
    mostrarUsuario();
  }

  checkLoginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getInt("id") == null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
          (Route<dynamic> route) => false);
    }
  }

  //toma el email por medio de sharedpreferences
  Future guardarUsuario() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var jsonResponse;
    sharedPreferences.setString("email", jsonResponse['email']);
  }

  //guarda el email obtendido por sharedpreferences
  Future mostrarUsuario() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      usuario = sharedPreferences.getString("email");
    });
    print(usuario);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Perfil", style: TextStyle(color: Colors.white)),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              sharedPreferences.clear();
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (BuildContext context) => LoginPage()),
                  (Route<dynamic> route) => false);
            },
            child: Text("Log Out", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            Color.fromRGBO(62, 15, 31, 1),
            Color.fromRGBO(135, 22, 52, 1)
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GenerateScreen()),
                      );
                    },
                    child: const Text('GENERAR CÓDIGO QR'))
                //Expanded(flex: 2, child: Image.asset('assets/qr.png'))
              ],
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: new ListView(
          children: <Widget>[
            new UserAccountsDrawerHeader(
              //muestra email de usuario actual en la pantalla de inicio
              accountName: new Text('UEES'),
              accountEmail: Text(usuario ?? ""),
              currentAccountPicture: GestureDetector(
                child: CircleAvatar(
                  //muestra imagen en la pantalla de inicio
                  backgroundColor: Colors.black,
                  backgroundImage: NetworkImage(
                      'https://pbs.twimg.com/profile_images/1212815999470358534/2eqDVz0n.jpg'),
                ),
              ),
            ),
            new ListTile(
              title: new Text("Pases Recibidos"),
              trailing: new Icon(Icons.arrow_circle_down_sharp),
              onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => ListItems(),
              )),
            ),
            new Divider(),
            new ListTile(
              title: new Text("Pases Enviados"),
              trailing: new Icon(Icons.arrow_circle_up),
              onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => ListItems(),
              )),
            ),
            new Divider(),
            new ListTile(
              title: new Text("Crear Pase"),
              trailing: new Icon(Icons.add_circle),
              onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => LoginPage(), //
              )),
            ),
            new Divider(),
            new ListTile(
                title: new Text("Log Out"),
                trailing: new Icon(Icons.logout),
                onTap: () {
                  sharedPreferences.clear();
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (BuildContext context) => LoginPage()),
                      (Route<dynamic> route) => false);
                }),
          ],
        ),
      ),
    );
  }
}
