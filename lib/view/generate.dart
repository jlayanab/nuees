//import 'package:esys_flutter_share/esys_flutter_share.dart';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uees/Controllers/program.dart';
import 'package:share_plus/share_plus.dart';
import 'package:share/share.dart' as sha;
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;

class GenerateScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => GenerateScreenState();
}

class GenerateScreenState extends State<GenerateScreen> {
  static const double _topSectionTopPadding = 50.0;
  static const double _topSectionBottomPadding = 20.0;
  //static const double _topSectionHeight = 50.0;
  String _dataString; //variable donde se guarda el código QR generado
  SharedPreferences sharedPreferences;
  Program program = new Program();

  GlobalKey globalKey = new GlobalKey();
  //String _inputErrorText;

  //final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    mostrarDatos();
  }

  //Toma el valor de Identification por medio de SharedPreference
  Future guardarDatos() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var jsonResponse;
    sharedPreferences.setString(
        "Identification", jsonResponse['Identification']);
  }

  //Guarda el valor de Identification en una variable llamada _dataString
  Future mostrarDatos() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      _dataString = sharedPreferences.getString("Identification");
      var text = program.codificar();
      _dataString = text;
      print(text.toString());
    });
    print(_dataString);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Código QR'),
        backgroundColor: Color.fromRGBO(62, 15, 31, 1),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.share),
            onPressed: _captureAndSharePng ?? "",
            //onPressed: shareScreenshot ?? "",
          )
        ],
      ),
      body: _contentWidget(context),
    );
  }

  Future<Null> shareScreenshot() async {
    setState(() {
      //button1 = true;
    });
    try {
      RenderRepaintBoundary boundary =
          globalKey.currentContext.findRenderObject();
      if (boundary.debugNeedsPaint) {
        Timer(Duration(seconds: 1), () => shareScreenshot());
        return null;
      }
      ui.Image image = await boundary.toImage();
      final directory = (await getExternalStorageDirectory()).path;
      ByteData byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();
      File imgFile = new File('$directory/screenshot.png');
      imgFile.writeAsBytes(pngBytes);
      final RenderBox box = context.findRenderObject();

      sha.Share.shareFiles(['$directory/screenshot.png'],
          subject: 'Share ScreenShot',
          text: 'Hello, check your share files!',
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    } on PlatformException catch (e) {
      print("Exception while taking screenshot:" + e.toString());
    }
    setState(() {});
  }

  //transparent to white(255,255,255,255)
  Future<List<int>> alphaToWhite(ui.Image source) async {
    Uint8List bytes = (await source.toByteData(format: ImageByteFormat.rawRgba)).buffer.asUint8List();
    for(int i = 3; i<bytes.length; i+=4) {
      //if pixel is transparent
      if(bytes[i] == 0) {
        bytes[i]   = 255; //no transparent
        bytes[i-3] = 255; //Red to 255
        bytes[i-2] = 255; //Green to 255
        bytes[i-1] = 255; //Blue to 255
      }
    }
    img.Image bytesImage = img.Image.fromBytes(source.width, source.height, bytes);
    return img.encodePng(bytesImage);
  }

  Future<void> _captureAndSharePng() async {
    // ignore: unused_local_variable
    bool inside = false;
    try {
      print('inside');
      inside = true;
      RenderRepaintBoundary boundary =
          globalKey.currentContext.findRenderObject();
      var image = await alphaToWhite(await boundary.toImage());
      Uint8List pngBytes = Uint8List.fromList(image);

      //print(bs64);

      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/image.png';
      final path2 = '${tempDir.path}/image.jpg';
      final file = await new File(path).create();
      await file.writeAsBytes(pngBytes);

      File(path2).writeAsBytesSync(pngBytes);

      //await Share.shareFiles([path], text: "Prueba");
      await Share.shareFiles([path]);

      //Share.file("Invitación Codigo QR", "Codigo.png", pngBytes, "image/png");
      //final channel = const MethodChannel('channel:me.camellabs.share/share');
      //channel.invokeMethod('shareFile', 'image.png');
    } catch (e) {
      print(e.toString());
    }
  }

  _contentWidget(context) {
    final bodyHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewInsets.bottom;
    return Container(
      //color: Color.fromRgb(255, 255, 255),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              top: _topSectionTopPadding,
              left: 20.0,
              right: 10.0,
              bottom: _topSectionBottomPadding,
            ),
            //child: Container(
            //height: _topSectionHeight,
            //child: Row(
            //mainAxisSize: MainAxisSize.max,
            //crossAxisAlignment: CrossAxisAlignment.stretch,
            //children: <Widget>[
            //Expanded(
            //child: TextField(
            //controller: _textController,
            //decoration: InputDecoration(
            //hintText: "Enter a custom message",
            //errorText: _inputErrorText,
            //),
            //),
            //),
            //Padding(
            //padding: const EdgeInsets.only(left: 10.0),
            //child: FlatButton(
            //child: Text("SUBMIT"),
            //onPressed: () {
            //setState(() {
            //dataString = _textController.text;
            //inputErrorText = null;
            //});
            //},
            //),
            //)
            //],
            //),
            //),
          ),
          Expanded(
            child: Center(
              child: RepaintBoundary(
                key: globalKey,
                child: QrImage(
                  data: _dataString ??
                      "", //Genera código QR mediante el valor de Identification
                  size: 0.5 * bodyHeight,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
