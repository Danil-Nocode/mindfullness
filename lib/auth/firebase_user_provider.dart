import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

class MindfullnessFirebaseUser {
  MindfullnessFirebaseUser(this.user);
  User? user;
  bool get loggedIn => user != null;
}

MindfullnessFirebaseUser? currentUser;
bool get loggedIn => currentUser?.loggedIn ?? false;
Stream<MindfullnessFirebaseUser> mindfullnessFirebaseUserStream() =>
    FirebaseAuth.instance
        .authStateChanges()
        .debounce((user) => user == null && !loggedIn
            ? TimerStream(true, const Duration(seconds: 1))
            : Stream.value(user))
        .map<MindfullnessFirebaseUser>(
      (user) {
        currentUser = MindfullnessFirebaseUser(user);
        return currentUser!;
      },
    );
