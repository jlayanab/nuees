import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uees/main.dart';
import 'package:uees/view/confirmation.dart';
import 'package:uees/view/registerUsr.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  final TextEditingController emailController =
      new TextEditingController(); //Guarda valor de email ingresado por el usuario por pantalla
  final TextEditingController passwordController =
      new TextEditingController(); //Guarda valor de password ingresado por el usuario por pantalla

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light
        .copyWith(statusBarColor: Colors.transparent));
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            Color.fromRGBO(62, 15, 31, 1),
            Color.fromRGBO(135, 22, 52, 1)
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView(
                children: <Widget>[
                  headerSection(),
                  textSection(),
                  buttonSection(),
                  buttonRegister(),
                ],
              ),
      ),
    );
  }

  //Función para iniciar sesión por el web service Uees
  signInUees(String usuario, clave) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var jsonResponse;
    String mUrl = "http://200.1.161.199:8080/apiApp/informacion/usuario/login";
    Map<String, String> queryParams = {
      'usuario': '$usuario',
      'clave': '$clave'
    };
    String queryString = Uri(queryParameters: queryParams).query;
    var requestUrl = mUrl + '?' + queryString;

    http.Response response = await http.get(requestUrl);

    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body.toString());
      print(response.statusCode);
      print(json.decode(response.body));
      if (jsonResponse != null) {
        setState(() {
          _isLoading = false;
        });
        //guarda datos del usuario logueado por sharedPreferences
        sharedPreferences.setString("cod_usuario", jsonResponse['cod_usuario']);
        sharedPreferences.setString(
            "cod_identificacion", jsonResponse['cod_identificacion']);
        sharedPreferences.setString("nombres", jsonResponse['nombres']);
        sharedPreferences.setString("apellidos", jsonResponse['apellidos']);
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (BuildContext context) => Confirmation()),
            (Route<dynamic> route) => false);
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      print(response.body.toString());
    }
  }

  //Función para iniciar sesión desde servidor rails
  signIn(String email, pass) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map data = {'email': email, 'password': pass};
    var jsonResponse;

    var response = await http
        .post("http://181.39.198.36:3000/api/v1/authenticate", body: data);
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      //print('Response status: ${response.statusCode}');
      //print('Response body: ${response.body}');
      if (jsonResponse != null) {
        setState(() {
          _isLoading = false;
        });
        //guarda datos del usuario logueado por sharedPreferences
        sharedPreferences.setString("token", jsonResponse['token']);
        sharedPreferences.setInt("id", jsonResponse['id']);
        sharedPreferences.setString(
            "Identification", jsonResponse['Identification']);
        sharedPreferences.setBool("avatar", jsonResponse['avatar']);
        sharedPreferences.setString("file", jsonResponse['file']);
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) => MainPage()),
            (Route<dynamic> route) => false);
      }
    } //condicion para verificar si el usuario existe o inicia sesion desde web service
    else if (response.statusCode == 401) {
      //signInUees(emailController.text, passwordController.text);
      setState(() {
        _isLoading = false;
      });
      await _showMyDialod();
      //Navigator.push(
      //    context, MaterialPageRoute(builder: (context) => LoginPage()));
    }
  }

  Future<void> _showMyDialod() async {
    return await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('UEES'),
            content: SingleChildScrollView(
              child: ListBody(
                children: const <Widget>[
                  Text('Usuario o password'),
                  Text('incorrecto')
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  Container buttonSection() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 40.0,
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      margin: EdgeInsets.only(top: 15.0),
      child: ElevatedButton(
        onPressed: emailController.text == "" || passwordController.text == ""
            ? null
            : () async {
                setState(() {
                  _isLoading = true;
                });
                signIn(emailController.text, passwordController.text);
                //guarda valores de email y password del inicio de sesion por sharedpreferences
                SharedPreferences sharedPreferences =
                    await SharedPreferences.getInstance();
                sharedPreferences.setString("email", emailController.text);
                sharedPreferences.setString("pass", passwordController.text);
              },
        style: ElevatedButton.styleFrom(
          primary: Colors.pink[900], // background
        ),
        child: Text("Sign In", style: TextStyle(color: Colors.white70)),
        //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      ),
    );
  }

  Container headerSection() {
    return Container(
      margin: EdgeInsets.only(top: 50.0),
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
      child: Center(
        child: Text("UEES",
            style: TextStyle(
                color: Colors.white70,
                fontSize: 70.0,
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  Container textSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: emailController,
            cursorColor: Colors.white,
            style: TextStyle(color: Colors.white70),
            decoration: InputDecoration(
              icon: Icon(Icons.email, color: Colors.white70),
              hintText: "Usuario",
              border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70)),
              hintStyle: TextStyle(color: Colors.white70),
            ),
          ),
          SizedBox(height: 30.0),
          TextFormField(
            controller: passwordController,
            cursorColor: Colors.white,
            obscureText: true,
            style: TextStyle(color: Colors.white70),
            decoration: InputDecoration(
              icon: Icon(Icons.lock, color: Colors.white70),
              hintText: "Password",
              border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70)),
              hintStyle: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Container buttonRegister() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 40.0,
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      margin: EdgeInsets.only(top: 15.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Colors.pink[900], // background
        ),
        child: Text("Registrarse", style: TextStyle(color: Colors.white70)),
        //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        onPressed: () {
          Navigator.of(context).push(new MaterialPageRoute(
              builder: (BuildContext context) => SignupPage()));
        },
      ),
    );
  }
}
