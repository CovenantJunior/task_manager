import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/controllers/todo_list_controller.dart';
import 'package:task_manager/services/notification_service.dart';
import 'package:task_manager/layouts/splash.dart';


Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      foregroundServiceNotificationId: 144000,

      initialNotificationTitle: "Stay Productive",
      initialNotificationContent: "Take one step at a time and keep moving forward.",
      autoStart: true,
      onStart: onStart,
      isForegroundMode: true,
    ),

    iosConfiguration: IosConfiguration(      
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}


@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  // print("Started");
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });
}

void initializeAIKeys() async {
  // GEMINI_API_KEY (.env)
  await dotenv.load(fileName: ".env");
  String? apiKey = dotenv.env['GEMINI_API_KEY'];
  Gemini.init(apiKey: apiKey!, enableDebugging: true);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().initNotifications();
  initializeService();
  initializeAIKeys();
  await TodoListDatabase.initialize();
  runApp(
    MultiProvider(
      providers: [
        // TodoList Database Provider
        ChangeNotifierProvider(
          create: (context) => TodoListDatabase(),
        )
      ],
      child: const MyApp()
    )
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  void initializePreference() async {
    context.read<TodoListDatabase>().fetchPreferences();
  }

  @override
  Widget build(BuildContext context) {
    initializePreference();
    return Consumer<TodoListDatabase>(
      builder: (context, todoListDatabase, child) {
        return MaterialApp(
          theme: todoListDatabase.preferences.first.darkMode
              ? ThemeData.dark()
              : ThemeData.light(),
          debugShowCheckedModeBanner: false,
          home: const Splash()
        );
      },
    );
  }
}