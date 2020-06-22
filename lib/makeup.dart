import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:googleapis/pagespeedonline/v5.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:image_picker/image_picker.dart';
import 'package:googleapis/ml/v1.dart' as ml;
import 'package:googleapis/discovery/v1.dart' as discovery;
import 'package:_discoveryapis_commons/_discoveryapis_commons.dart' as commons;
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'dart:io' as Io;
import 'package:mime/mime.dart';
import 'dart:convert';
import 'package:http_parser/http_parser.dart';

class Makeup extends StatefulWidget {
  @override
  _MakeupState createState() => _MakeupState();
}



class _MakeupState extends State<Makeup> {
  String _outputs;
  File _image;
  bool _loading = false;
  Uint8List pixel;

  String baseUrl = 'https://bangkit-demo.herokuapp.com/predict';

  Future<http.Response> _uploadImage(File image) async {
    final mimeTypeData =
    lookupMimeType(image.path, headerBytes: [0xFF, 0xD8]).split('/');
    final imageUploadRequest = http.MultipartRequest('POST', Uri.parse(baseUrl));
    final file = await http.MultipartFile.fromPath('file', image.path,
        contentType: MediaType(mimeTypeData[0], mimeTypeData[1]));
    imageUploadRequest.fields['ext'] = mimeTypeData[1];
    imageUploadRequest.files.add(file);
    try {
      print("MAU DIKIRIM");
      print(imageUploadRequest.toString());
      final streamedResponse = await imageUploadRequest.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode != 200) {
        print("STATUS 200");
        print(response.body);
        return null;}
      print(response.body);
      //final Map<String, dynamic> responseData = json.decode(response.body);
      setState(() {
        _loading = false;
        _outputs = response.body.toString();
      });;
      return response;
    } catch (e) {
      print("ERROR");
      print(e);
      return null;
    }
  }



  pickImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    setState(() {
      _loading = true;
      _image = image;
    });
    print("GAMBAR UDAH MASUK");
    print(image.path);
    final http.Response response = await _uploadImage(image);
    print(response);
  }

  @override
  void initState() {
    // TODO: implement setState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: Text("Makeup")),
      body: SingleChildScrollView(
        child: Container(
          width: size.width,
          child: _loading
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
                _image == null ? Container() : Image.file(_image),
                SizedBox(
                  height: 20,
                ),
                _outputs != null
                    ? Text(
                  "$_outputs",
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
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: pickImage,
        child: Icon(Icons.image),
      ),
    );
  }


}

