import 'package:googleapis/androidpublisher/v3.dart' as androidPublisher;
import 'package:googleapis_auth/auth_io.dart' as auth;



final _credentials = new auth.ServiceAccountCredentials.fromJson(r'''
      {
        "private_key_id": ...,
        "private_key": ...,
        "client_email": ...,
        "client_id": ...,
        "type": "service_account"
      }
      ''');

const _SCOPES = const [
  androidPublisher.AndroidpublisherApi.AndroidpublisherScope
];

