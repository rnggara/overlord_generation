import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:overlord_generation/activitiy/create_char.dart';
import 'package:overlord_generation/activitiy/create_family.dart';
import 'package:overlord_generation/activitiy/user_screen.dart';
import 'package:overlord_generation/res/values.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Authentication {
  static SnackBar customSnackBar({required String content}) {
    return SnackBar(
      backgroundColor: Colors.black,
      content: Text(
        content,
        style: const TextStyle(color: Colors.redAccent, letterSpacing: 0.5),
      ),
    );
  }

  static Future<FirebaseApp> initializeFirebase({
    required BuildContext context,
  }) async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final uri = Uri.parse("$baseUri/og/check-email");

      final _post = {
        "email": user.email,
      };

      var hasChild = false;
      var hasFamily = false;
      SharedPreferences pref = await SharedPreferences.getInstance();

      try {
        final response = await http.post(uri, body: _post);

        final data = json.decode(response.body);

        var msg = "";
        if (data['success']) {
          final _data = data['data'];
          final _user = _data['user'];
          var _child = _data['char'];
          var _items = _data['items'];
          hasFamily = true;
          if (_child.length > 0) {
            hasChild = true;
            await pref.setString('uId', _user['id'].toString());
            await pref.setString('email', user.email.toString());
            await pref.setString('charData', json.encode(_child).toString());
            await pref.setString('userData', json.encode(_user).toString());
            await pref.setString('itemsData', json.encode(_items).toString());
          }
        }
      } catch (e) {}

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => hasFamily
              ? hasChild
                  ? UserScreen(pref: pref)
                  : CreateChar(user: user)
              : CreateFamily(
                  user: user,
                ),
        ),
      );
    }

    return firebaseApp;
  }

  static Future<User?> signInWithGoogle({required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;
    if (kIsWeb) {
      GoogleAuthProvider authProvider = GoogleAuthProvider();

      try {
        final UserCredential userCredential =
            await auth.signInWithPopup(authProvider);

        user = userCredential.user;
      } catch (e) {
        log(e.toString());
      }
    } else {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        try {
          final UserCredential userCredential =
              await auth.signInWithCredential(credential);

          user = userCredential.user;
        } on FirebaseAuthException catch (e) {
          if (e.code == 'account-exists-with-different-credential') {
            ScaffoldMessenger.of(context).showSnackBar(
              Authentication.customSnackBar(
                content:
                    'The account already exists with a different credential',
              ),
            );
          } else if (e.code == 'invalid-credential') {
            ScaffoldMessenger.of(context).showSnackBar(
              Authentication.customSnackBar(
                content:
                    'Error occurred while accessing credentials. Try again.',
              ),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            Authentication.customSnackBar(
              content: 'Error occurred using Google Sign In. Try again.',
            ),
          );
        }
      }
    }

    return user;
  }

  static Future<void> signOut({required BuildContext context}) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      if (!kIsWeb) {
        await googleSignIn.signOut();
      }
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        Authentication.customSnackBar(
          content: 'Error signing out. Try again.',
        ),
      );
    }
  }
}
