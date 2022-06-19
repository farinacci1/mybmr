import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:mybmr/models/AppUser.dart';

import 'package:mybmr/services/Firebase_db.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class UserNotifier extends ChangeNotifier {




  bool executingAction = false;
  bool actionComplete = true;


  void reset(){
    executingAction = false;
    actionComplete = true;
  }
  Future<void> refresh() async {

    notifyListeners();
  }
  Future<void> signInWithGoogle() async {
    executingAction = true;
    actionComplete = false;
    final GoogleSignIn _googleSignIn =await GoogleSignIn();
    final googleUser = await _googleSignIn.signIn();
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken
    );
    FirebaseAuth.instance.signInWithCredential(credential).then((UserCredential userCredential){
      AppUser.instance.uuid =userCredential.user.uid;
      AppUser.instance.signInMethod = "google";
      pollForUser();


    }).whenComplete((){
      executingAction = false;
      notifyListeners();
      actionComplete = true;

    });


   
  }

  Future<void> signInWithApple() async{
    executingAction = true;
    actionComplete = false;
    var redirectURL = "https://mybmr-f3824.firebaseapp.com/__/auth/handler";
    var clientID = "com.bmrteam.mybmr";
     final appleIdCredential = await SignInWithApple.getAppleIDCredential(
       scopes: [],
         webAuthenticationOptions: WebAuthenticationOptions(
             clientId: clientID,
             redirectUri: Uri.parse(
                 redirectURL)));
    final oAuthProvider = OAuthProvider('apple.com');
    final credential = oAuthProvider.credential(
      idToken: appleIdCredential.identityToken,
      accessToken: appleIdCredential.authorizationCode,
    );
    FirebaseAuth.instance.signInWithCredential(credential).then((UserCredential userCredential){
      AppUser.instance.uuid =userCredential.user.uid;
      AppUser.instance.signInMethod = "apple";


    }).whenComplete(() {
      actionComplete = true;
      executingAction = false;
      notifyListeners();
    });
  }
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    reset();
    AppUser.instance.clear();
    notifyListeners();
  }
  Future<void> pollForUser({Function callback}) async {
      FirebaseDB.createUserIfNotExists( AppUser.instance.uuid ).then((userDocument) async {
        if(userDocument.exists){
          AppUser.instance.fromJSON(userDocument.data());
          if(callback != null)callback();

        }
        else{
          // print("nothing found");
          AppUser.instance.clear();
        }


      }).whenComplete(() {
        notifyListeners();
      });



  }



}