import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      print("Terminal Log: Login Success: ${result.user?.email}");
      return result.user;
    } catch (e) {
      print("Terminal Log Error: Login Failed: $e");
      return null;
    }
  }

  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      print("Terminal Log: User Registered: ${result.user?.email}");
      return result.user;
    } catch (e) {
      print("Terminal Log Error: Signup Failed: $e");
      return null;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    print("Terminal Log: User Logged Out");
  }

  User? get currentUser => _auth.currentUser;
}