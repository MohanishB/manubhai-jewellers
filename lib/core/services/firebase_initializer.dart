// import 'dart:io';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:manubhaimlt/core/services/firebase_options.dart';
// import 'package:permission_handler/permission_handler.dart';

// /// Global singletons
// final FirebaseMessaging fcm = FirebaseMessaging.instance;
// final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
// final FlutterLocalNotificationsPlugin localNotifications = FlutterLocalNotificationsPlugin();

// /// ✅ Background message handler (when app is in background or terminated)
// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   print('📩 [BACKGROUND] Message ID: ${message.messageId}');
//   print('📩 [BACKGROUND] Title: ${message.notification?.title}');
//   print('📩 [BACKGROUND] Body: ${message.notification?.body}');
//   print('📩 [BACKGROUND] Data: ${message.data}');
// }

// class FirebaseInitializer {
//   static Future<void> initialize() async {
//     // ✅ Initialize Firebase
//     await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

//     // ✅ Register background handler
//     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//     // ✅ Ask for permission (iOS + Android 13+)
//     await _requestNotificationPermission();

//     // ✅ Initialize local notifications
//     const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
//     const iosInit = DarwinInitializationSettings();
//     const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
//     await localNotifications.initialize(initSettings);

//     // ✅ Handle foreground messages
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       print('📩 [FOREGROUND] Message received!');
//       print('📩 Title: ${message.notification?.title}');
//       print('📩 Body: ${message.notification?.body}');
//       print('📩 Data: ${message.data}');

//       // Show local notification
//       final notification = message.notification;
//       if (notification != null) {
//         localNotifications.show(
//           notification.hashCode,
//           notification.title,
//           notification.body,
//           const NotificationDetails(
//             android: AndroidNotificationDetails(
//               'default_channel',
//               'Default Notifications',
//               importance: Importance.max,
//               priority: Priority.high,
//             ),
//             iOS: DarwinNotificationDetails(),
//           ),
//         );
//       }
//     });

//     // ✅ Handle tap when app is opened from background
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       print('🔔 [TAP] Notification opened from background');
//       print('🔔 Data: ${message.data}');
//     });

//     // ✅ Handle message that opened the app from a terminated state
//     final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
//     if (initialMessage != null) {
//       print('🚀 [TERMINATED → OPENED] Notification caused app launch');
//       print('🚀 Data: ${initialMessage.data}');
//     }

//     // ✅ Print FCM token for debugging
//     final token = await fcm.getToken();
//     print('📱 [FCM Token] $token');
//   }

//   /// ✅ Request permissions
//   static Future<void> _requestNotificationPermission() async {
//     if (Platform.isIOS) {
//       await fcm.requestPermission(alert: true, badge: true, sound: true);
//     } else if (Platform.isAndroid) {
//       final status = await Permission.notification.status;
//       if (status.isDenied || status.isPermanentlyDenied) {
//         await Permission.notification.request();
//       }
//     }
//   }
// }

//==============================================

// import 'dart:convert';
// import 'dart:io';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:manubhaimlt/app/router.dart';
// import 'package:manubhaimlt/core/services/firebase_options.dart';
// import 'package:manubhaimlt/features/auth/bloc/auth_bloc.dart';
// import 'package:manubhaimlt/features/auth/bloc/auth_state.dart';
// import 'package:manubhaimlt/features/mlt/products/bloc/CSE/receivedSafe/received_safe_bloc.dart';
// import 'package:manubhaimlt/features/mlt/products/bloc/CSE/receivedSafe/received_safe_event.dart';
// import 'package:manubhaimlt/features/mlt/products/bloc/store_keeper/safe_keeper_bloc.dart';
// import 'package:manubhaimlt/features/mlt/products/bloc/store_keeper/safe_keeper_event.dart';
// import 'package:permission_handler/permission_handler.dart';

// /// 🔥 Global singletons
// final FirebaseMessaging fcm = FirebaseMessaging.instance;
// final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
// final FlutterLocalNotificationsPlugin localNotifications =
//     FlutterLocalNotificationsPlugin();

// /// ✅ Handles messages when app is in background or terminated
// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   print('📩 [BACKGROUND] Message ID: ${message.messageId}');
//   print('📩 [BACKGROUND] Title: ${message.notification?.title}');
//   print('📩 [BACKGROUND] Body: ${message.notification?.body}');
//   print('📩 [BACKGROUND] Data: ${message.data}');
// }

// class FirebaseInitializer {
//   static Future<void> initialize() async {
//     await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//     await _requestNotificationPermission();

//     // ✅ Local notifications setup
//     const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
//     const iosInit = DarwinInitializationSettings();
//     const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
//     await localNotifications.initialize(
//       initSettings,
//       onDidReceiveNotificationResponse: (NotificationResponse response) async {
//         if (response.payload != null) {
//           print('🔔 [LOCAL TAP] Payload: ${response.payload}');
//           final data = Map<String, dynamic>.from(jsonDecode(response.payload!));
//           final msg = RemoteMessage(data: data);
//           handleNotificationNavigation(msg);
//         }
//       },
//     );

//     // await localNotifications.initialize(initSettings,
//     //     onDidReceiveNotificationResponse: (NotificationResponse response) async {
//     //   // Handles tap from foreground notification
//     //   if (response.payload != null) {
//     //     print('🔔 [LOCAL TAP] Payload: ${response.payload}');
//     //   }
//     // });

//     // ✅ Foreground messages
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       print('📩 [FOREGROUND] Message received!');
//       print('📩 Title: ${message.notification?.title}');
//       print('📩 Body: ${message.notification?.body}');
//       print('📩 Data: ${message.data}');

//       final notification = message.notification;
//       if (notification != null) {
//         localNotifications.show(
//           notification.hashCode,
//           notification.title,
//           notification.body,
//           const NotificationDetails(
//             android: AndroidNotificationDetails(
//               'default_channel',
//               'Default Notifications',
//               importance: Importance.max,
//               priority: Priority.high,
//             ),
//             iOS: DarwinNotificationDetails(),
//           ),
//            payload: jsonEncode(message.data),
//         );
//       }
//     });

//     // ✅ When app is opened from background by tapping notification
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       print('🚀 listen [TAP] Notification opened from BACKGROUND');
//       print('🚀 listen Data: ${message.data}');
//       handleNotificationNavigation(message);
//     });

//     // ✅ When app is opened from a terminated state
//     final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
//     if (initialMessage != null) {
//       print('🚀 getInitialMessage [TAP] Notification opened from TERMINATED');
//       print('🚀 getInitialMessage Data: ${initialMessage.data}');
//       handleNotificationNavigation(initialMessage);
//     }

//     // ✅ Print token for debugging
//     final token = await fcm.getToken();
//     print('📱 [FCM Token] $token');
//   }

//   /// ✅ Handle permission (iOS + Android 13+)
//   static Future<void> _requestNotificationPermission() async {
//     if (Platform.isIOS) {
//       await fcm.requestPermission(alert: true, badge: true, sound: true);
//     } else if (Platform.isAndroid) {
//       final status = await Permission.notification.status;
//       if (status.isDenied || status.isPermanentlyDenied) {
//         await Permission.notification.request();
//       }
//     }
//   }

//   /// ✅ Handles navigation + refresh logic after tapping notification
//   static void handleNotificationNavigation(RemoteMessage message) {
//     final data = message.data;
//     final clickUrl = data['click_url'];
//     final ctx = rootNavigatorKey.currentContext;

//     if (ctx == null) {
//       print('❌ [NAVIGATION] Context not ready yet.');
//       return;
//     }

//     final authState = ctx.read<AuthBloc>().state;
//     if (authState is! AuthAuthenticated) {
//       print('⚠️ [NAVIGATION] User not authenticated yet, skipping.');
//       return;
//     }
//     final userId = authState.user.id;

//     print('🔀 [NAVIGATION] click_url: $clickUrl');

//     if (clickUrl == 'cse_request_out_from_safe_stock_list') {
//       // ✅ 1. Navigate to DashboardCSEScreen
//       ctx.go('/a');
//       // ✅ 2. Then automatically open ReceivedSafeScreen
//       // Future.delayed(const Duration(milliseconds: 600), () {
//       Future.delayed(const Duration(seconds: 1), () async {
//         ctx.push('/a/received-safe');

//         // ✅ Refresh Received Safe list
//         final bloc = ctx.read<ReceivedSafeBloc?>();
//         if (bloc != null) {
//           bloc.add(FetchReceivedSafeList(userId));
//           print('🔁 [CSE] Refreshed ReceivedSafeScreen');
//         } else {
//           print('⚠️ [CSE] ReceivedSafeBloc not found');
//         }
//       });
//     }

//     else if (clickUrl == 'safe_keeper_request_received_list') {
//       // ✅ 1. Navigate to DashboardStoreKeeperScreen
//       ctx.go('/b');

//       // ✅ 2. Refresh StoreKeeper requests after short delay
//       // Future.delayed(const Duration(milliseconds: 600), () {
//       Future.delayed(const Duration(seconds: 1), () async {
//         final bloc = ctx.read<SafeKeeperBloc?>();
//         if (bloc != null) {
//           bloc.add(FetchSafeKeeperRequests(userId));
//           print('🔁 [STOREKEEPER] Refreshed requests');
//         } else {
//           print('⚠️ [STOREKEEPER] SafeKeeperBloc not found');
//         }
//       });
//     } else {
//       print('ℹ️ [NAVIGATION] Unrecognized click_url: $clickUrl');
//     }
//   }
// }

//==============================================


import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import 'firebase_options.dart';

/// 🔥 Global singletons
final FirebaseMessaging fcm = FirebaseMessaging.instance;
final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
final FlutterLocalNotificationsPlugin localNotifications =
    FlutterLocalNotificationsPlugin();

/// ✅ Handles messages when app is in background/terminated (DART isolate)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('📩 [BACKGROUND HANDLER] Message ID: ${message.messageId}');
  print('📩 [BACKGROUND HANDLER] Data: ${message.data}');
}

class FirebaseInitializer {
  static const String _channelId = 'default_channel';
  static const String _channelName = 'Default Notifications';

  static Future<void> initialize() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _requestNotificationPermission();
    await _initLocalNotifications();
    _initFCMListeners();

    final token = await fcm.getToken();
    print('📱 [FCM TOKEN] $token');
  }

  static Future<void> _requestNotificationPermission() async {
    if (Platform.isIOS) {
      await fcm.requestPermission(alert: true, badge: true, sound: true);
    }
    // Android 13+ permission handled already by your permission_handler flow elsewhere if needed.
    if (Platform.isAndroid) {
      final androidPlugin =
          localNotifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        print('🔐 [Android Permission - local_notifications] granted=$granted');
      } else {
        // fallback (rare)
        final status = await Permission.notification.status;
        if (status.isDenied || status.isPermanentlyDenied) {
          final res = await Permission.notification.request();
          print('🔐 [Android Permission - permission_handler] $res');
        }
      }
    }

  }

  static Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings =
        InitializationSettings(android: androidInit, iOS: iosInit);

    await localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse resp) async {
        // ✅ Foreground local-notification tap comes here
        final payload = resp.payload;
        if (payload == null || payload.isEmpty) return;

        try {
          final data = jsonDecode(payload);
          print('🔔 [LOCAL TAP] $data');
          // We do NOT navigate here (no context). App-level listener will handle it.
          NotificationTapBus.emit(Map<String, dynamic>.from(data));
        } catch (e) {
          print('⚠️ [LOCAL TAP] payload parse failed: $e');
        }
      },
    );

    // ✅ Create Android channel (required for Android 8+)
    final androidPlugin = localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          importance: Importance.max,
        ),
      );
    }
  }

  static void _initFCMListeners() {
    // ✅ Foreground FCM -> show local notification with payload (so tap works)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📩 [FOREGROUND] Title: ${message.notification?.title}');
      print('📩 [FOREGROUND] Body: ${message.notification?.body}');
      print('📩 [FOREGROUND] Data: ${message.data}');

      final n = message.notification;
      if (n == null) return;

      localNotifications.show(
        n.hashCode,
        n.title,
        n.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: jsonEncode(message.data), // ✅ critical
      );
    });

    // ✅ Background -> user taps system notification -> comes here
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('🚀 [SYSTEM TAP - BACKGROUND] Data: ${message.data}');
      NotificationTapBus.emit(message.data);
    });

    // ❌ Do NOT call getInitialMessage() here (killed-state needs context later).
  }
}

/// Simple in-memory tap bus (app listens after UI is ready)
class NotificationTapBus {
  static final _controller = StreamController<Map<String, dynamic>>.broadcast();

  static Stream<Map<String, dynamic>> get stream => _controller.stream;

  static void emit(Map<String, dynamic> data) {
    _controller.add(Map<String, dynamic>.from(data));
  }
}
