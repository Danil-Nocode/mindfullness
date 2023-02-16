import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyD5ku5VDhgtoKtQqFCPI6mp_nIfOucLsGg",
            authDomain: "mindfulness-io.firebaseapp.com",
            projectId: "mindfulness-io",
            storageBucket: "mindfulness-io.appspot.com",
            messagingSenderId: "622912582763",
            appId: "1:622912582763:web:78d8fe07a7422d7fd52d2e"));
  } else {
    await Firebase.initializeApp();
  }
}
