import 'dart:io';
import 'package:flutter/material.dart';
import 'package:googleapis/pagespeedonline/v5.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:image_picker/image_picker.dart';
import 'package:googleapis/ml/v1.dart' as ml;
import 'package:googleapis/discovery/v1.dart' as discovery;

//const _SCOPES = const [
//  AndroidpublisherApi.AndroidpublisherScope
//];

class Makeup extends StatefulWidget {
  @override
  _MakeupState createState() => _MakeupState();
}



class _MakeupState extends State<Makeup> {

  predictJson({project,model,instances,version=""}) async {
    Map body = {'instances':instances};
    String name = 'projects/$project/models/$model';
    if(version!=""){
      name += '/versions/$version';
    }
    ml.GoogleCloudMlV1PredictRequest request = ml.GoogleCloudMlV1PredictRequest.fromJson({'httpBody':body});
    var response = await ml.ProjectsResourceApi().predict(request, name).then((value) => value.toJson());
    if(response.containsKey('error')){
      throw RuntimeError.fromJson(response);
    }
    return response['predictions'];
  }


  pickImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    setState(() {
      //_loading = true;
      _image = image;
    });
  }

  final _credentials = new ServiceAccountCredentials.fromJson(r'''
      {
        "private_key_id": ...,
        "private_key": ...,
        "client_email": ...,
        "client_id": ...,
        "type": "service_account"
      }
      ''');
  List _outputs;
  File _image;
  bool _loading = false;

  @override
  void initState() {
    // TODO: implement setState
    super.initState();
//    clientViaServiceAccount(_credentials, _SCOPES).then((httpClient) {
//      var publisher = new AndroidpublisherApi(httpClient);
//      publisher.purchases.products
//          .get(packageName, productID, purchaseToken)
//          .then((pub) {
//        debugPrint(pub.toJson().toString());
//      });
//    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
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
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: pickImage,
        child: Icon(Icons.image),
      ),
    );
  }


}

