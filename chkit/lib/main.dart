import 'package:chkit/screens/sign_in.dart';
import 'package:chkit/screens/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'models/user.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserId>.value(
      value: AuthService().user,
      initialData: UserId(uid: '0'),
      child: const MaterialApp(
        home: Wrapper(),
      ),
    );
  }
}