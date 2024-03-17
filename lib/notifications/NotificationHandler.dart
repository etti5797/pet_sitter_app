import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void sendPushNotification(String recipientToken, String senderName, String message) async {
  var url = Uri.parse('https://fcm.googleapis.com/fcm/send');
  var headers = {
    'Content-Type': 'application/json',
    'Authorization': 'key=AAAAZW_iPFc:APA91bHnyu7v-XFaQjaQ7K4DfED1kaKcfa9Bgg_yRJiZ6hzzE8waVK-_wx7m_RVgJqOQX40eHcAtKa_mdJlj7UBMmJ_32_LYkhT40XA5AvAuQmmpp5feJ6pc4BC451oNcEXYstRzNQoZ', // Replace YOUR_SERVER_KEY with your FCM server key
  };
  
  var body = {
    'to': recipientToken,
    'notification': {
      'title': 'New Message from $senderName',
      'body': message,
      'priority': 'high',
    },
    'data': {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'id': '1',
      'status': 'done',
      'senderName': senderName,
    }
  };

  var response = await http.post(
    url,
    headers: headers,
    body: json.encode(body),
  );

  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');
}


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher');

    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showNotification() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'channel_description',
      icon: 'ic_launcher',
    );

    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'Notification Title',
      'Notification Body',
      platformChannelSpecifics,
    );
  }
