
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void>handleBackgroundMessage(RemoteMessage Message)async{
  print('title: ${Message.notification?.title}');
   print('body: ${Message.notification?.body}');
    print('payload: ${Message.data}');
}


class FirebaseApi{
  final _FirebaseMessaging = FirebaseMessaging.instance;
  Future<void> initNotifications () async {
    await _FirebaseMessaging.requestPermission();
    final fcmToken =await _FirebaseMessaging.getToken();
    print('Token: $fcmToken');
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }
}



