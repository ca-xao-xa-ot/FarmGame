import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '45239781334-h7h559cmfatqpsedn6gpfgoakjvv3n0l.apps.googleusercontent.com',
  );

  // Đăng nhập bằng Email/Password
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return result.user;
    } catch (e) {
      print("Lỗi đăng nhập Email: $e");
      return null;
    }
  }

  // Đăng ký bằng Email/Password
  Future<User?> registerWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return result.user;
    } catch (e) {
      print("Lỗi đăng ký: $e");
      return null;
    }
  }

  // Đăng nhập bằng Google (Đã tối ưu cho Web)
  Future<User?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Dùng cơ chế Popup của Firebase (Cực mượt trên Chrome/Web)
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        UserCredential result = await _auth.signInWithPopup(googleProvider);
        return result.user;
      } else {
        // Dành cho Mobile (Android/iOS) sau này
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return null;

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        UserCredential result = await _auth.signInWithCredential(credential);
        return result.user;
      }
    } catch (e) {
      print("Lỗi đăng nhập Google: $e");
      return null;
    }
  }

  // Đăng xuất
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}