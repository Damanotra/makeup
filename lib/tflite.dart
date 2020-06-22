import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:googleapis/pagespeedonline/v5.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:googleapis/ml/v1.dart' as ml;
import 'package:googleapis/discovery/v1.dart' as discovery;
import 'package:tflite/tflite.dart';
import 'dart:io' as Io;

//const _SCOPES = const [
//  AndroidpublisherApi.AndroidpublisherScope
//];

class TfliteScreen extends StatefulWidget {
  @override
  _TfliteScreenState createState() => _TfliteScreenState();
}



class _TfliteScreenState extends State<TfliteScreen> {
  List _outputs;
  File _image;
  bool _loading = false;
  Uint8List pixel;

  pickImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    setState(() {
      _loading = true;
      _image = image;
    });
    resizeImage(image);
  }

  resizeImage(File image) async {
    img.Image _image = img.decodeImage(Io.File(image.path).readAsBytesSync());
    img.Image thumbnail = img.copyResize(_image, width: 150,height: 150);
    Uint8List listimg = thumbnail.getBytes();
    new Io.File('thumbnail-test.jpg')
      ..writeAsBytesSync(img.encodeJpg(thumbnail));
    image = Io.File('thumbnail-test.jpg');
    setState(() {
      _loading = false;
    });
  }

  classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.068,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _loading = false;
      _outputs = output;
    });
  }

//  classifyArray(File image) async {
//    var output = await Tflite.(
//      path: image.path,
//      numResults: 2,
//      threshold: 0.068,
//      imageMean: 127.5,
//      imageStd: 127.5,
//    );
//    setState(() {
//      _loading = false;
//      _outputs = output;
//    });
//  }

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/tflite/converted_makeup_model_v2.tflite",
      labels: "assets/tflite/labels_custom.txt",
    );
  }

  @override
  void initState() {
    // TODO: implement setState
    super.initState();
    _loading = true;
    loadModel().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("Makeup or no makeup"),
      ),
      body: _loading
          ? Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      )
          : Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //_image == null ? Container() : Image.file(_image),
            _image == null ? Container() : Image.file(_image),
            SizedBox(
              height: 20,
            ),
            _outputs != null
                ? Text(
              "${_outputs[0]["label"]}",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20.0,
                background: Paint()..color = Colors.white,
              ),
            )
                : Container()
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: pickImage,
        child: Icon(Icons.image),
      ),
    );
  }




}

