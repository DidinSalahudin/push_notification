import 'dart:io';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:push_notification/notification_handler.dart';

class FirebaseNotifications {
  late FirebaseMessaging _messaging;
  BuildContext? context;

  void setupFirebase(BuildContext context) {
    _messaging = FirebaseMessaging.instance;
    NotificationHandler.initNotification(context);
    firebaseCloudMessageListener(context);
  }

  void firebaseCloudMessageListener(BuildContext context) async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );
    print('Setting ${settings.authorizationStatus}');
    //Get token
    //We will use toke to revice notification
    _messaging.getToken().then((token) => print('MyToken: $token'));
    //Subscribe to topic
    //we will send to topic for group notification
    _messaging
        .subscribeToTopic("salahudin_demo")
        .whenComplete(() => print('Subcribe OK'));

    //handle message
    FirebaseMessaging.onMessage.listen((remoteMessage) {
      print('revice $remoteMessage');
      if (Platform.isAndroid) {
        showNotification(
            remoteMessage.data['title'], remoteMessage.data['body']);
      } else if (Platform.isIOS) {
        showNotification(
          remoteMessage.notification!.title,
          remoteMessage.notification!.body,
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((remoteMessage) {
      print('revice open app: $remoteMessage');
      if (Platform.isIOS) {
        showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text(remoteMessage.notification!.title!),
            content: Text(remoteMessage.notification!.body!),
            actions: [
              CupertinoDialogAction(
                child: Text('OK'),
                isDefaultAction: true,
                onPressed: () =>
                    Navigator.of(context, rootNavigator: true).pop(),
              ),
            ],
          ),
        );
      }
    });
  }

  static void showNotification(title, body) async {
    print('Title : $title , body : $body');
    var androidChanel = AndroidNotificationDetails(
      "com.salahudin.push_notification",
      'My Chanel',
      'Description',
      autoCancel: false,
      ongoing: false,
      importance: Importance.max,
      priority: Priority.high,
    );

    var ios = IOSNotificationDetails();

    var platform = NotificationDetails(android: androidChanel, iOS: ios);
    await NotificationHandler.flutterLocalNotificationsPlugin.show(
      Random().nextInt(1000),
      title,
      body,
      platform,
      payload: 'My Payload',
    );
  }
}
