import 'package:chkit/services/database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chkit/screens/home/home.dart';
import 'package:chkit/models/user.dart';

Color green = const Color(0xFF2E6B46);
Color orange = const Color(0xFFECB017);
Color ivory = const Color(0xFFEDE8DB);
Color darkRed = const Color(0xFF230505);

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // create user obj
  UserId _userFromFirebase(User user){
    return UserId(uid: user.uid);

  }

  // change user stream
  Stream<UserId> get user {
    return _auth.authStateChanges()
      .map((User? user) => _userFromFirebase(user!));
  }

  // sign in anon
  Future<UserId?> signInAnon() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User? user = result.user;

      await DatabaseService(uid: user!.uid).updateUserData('test task');

      return _userFromFirebase(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}

class _SignInState extends State<SignIn> {
  bool isLoading = true;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    performSignIn();
  }

  Future<void> performSignIn() async {
    UserId? user = await _authService.signInAnon();
    setState(() {
      isLoading = false;
    });
    if (user != null) {
      print('Signed in');
      print(user.uid);
      // Navigate to the Home page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
      );
    } else {
      print('Error signing in');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ivory,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: green,
        title: const Text(
          'Signing In...',
          style: TextStyle(fontFamily: 'Alata', fontSize: 28, color: Color(0xFFEDE8DB)),
        ),
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(green), 
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
