import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/services/notification_service.dart'; 
import 'bloc/todo_bloc.dart';
import 'bloc/todo_event.dart';
import 'pages/todo_list_page.dart';
import 'pages/login_page.dart'; 
import 'package:firebase_auth/firebase_auth.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Background fcm received: ${message.data}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp();

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await NotificationService.init(); 
    
    print("Firebase and Local Notifications initialized.");
  } catch (e) {
    print("Terminal Log Error: Initialization failed: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => TodoBloc()..add(LoadTodos()),
        ),
      ],
      child: MaterialApp(
        title: 'LMG Todo App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true, 
          brightness: Brightness.dark,
          colorSchemeSeed: Colors.blueAccent,
        ),
        home: FirebaseAuth.instance.currentUser == null 
              ? const LoginPage() 
              : const TodoListPage(),
      ),
    );
  }
}