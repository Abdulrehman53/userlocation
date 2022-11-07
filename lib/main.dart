import 'dart:async';

import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:userlocation/home_page.dart';
import 'package:userlocation/shared_preferences_storage.dart';

import 'home_page_user.dart';

void main() {
  // runApp(const MyApp());
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

    runApp(const MyApp());
  }, (error, stack) => FirebaseCrashlytics.instance.recordError(error, stack));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
      ),
      home: const LoginPage(),
      builder: EasyLoading.init(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  FirebaseAuth auth = FirebaseAuth.instance;
  UserCredential? userCredential;
  User? user;

  Future<bool?> firebaseAuthentication(name, email, password) async {
    if (name != '' && email != '' && password != '') {
      try {
        userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: _emailController.text.toString().toLowerCase(),
                password: _passwordController.text.toString().toLowerCase());
        if (userCredential!.user!.displayName == null) {
          await userCredential!.user!
              .updateDisplayName(name + "|user")
              .then((value) => print("done"));
        }
        user = FirebaseAuth.instance.currentUser!;
        print("===================");
        print(user!.displayName);
        print("===================");
        return true;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          print('The password provided is too weak.');
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('The password provided is too weak.'),
            backgroundColor: Colors.orange,
          ));
          return false;
        } else if (e.code == 'email-already-in-use') {
          print('The account already exists for that email.');
          try {
            userCredential = await FirebaseAuth.instance
                .signInWithEmailAndPassword(
                    email: _emailController.text.toString().toLowerCase(),
                    password:
                        _passwordController.text.toString().toLowerCase());
            user = FirebaseAuth.instance.currentUser!;
            return true;
          } on FirebaseAuthException catch (e) {
            if (e.code == 'user-not-found') {
              print('No user found for that email.');
              return false;
            } else if (e.code == 'wrong-password') {
              print('Wrong password provided for that user.');
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Wrong password provided for that user.'),
                backgroundColor: Colors.redAccent,
              ));
              return false;
            }
          }
        }
      } catch (e) {
        print(e);
        return false;
      }
    }
    return false;
  }

  late SharedPreferences sharedPreference;
  @override
  void initState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        if (user.displayName != null) {
          print(user.uid);
          print(user.email);
          print(user.displayName);
          print(user.metadata);
          // print(user.);

          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) => HomePageUser(
                        // title: user.displayName.toString(),
                        // email: user.email.toString(),
                        user: user,
                      )),
              (Route<dynamic> route) => false);
        }
      } else {
        sharedPreference = await SharedPreferences.getInstance();
        final isAutoLogin = await SharePreferencesStore.getPreferences(
            sharedPreference, 'isAutoLogin');
        if (isAutoLogin != null && isAutoLogin) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) => HomePageAdmin(
                        // title: user.displayName.toString(),
                        // email: user.email.toString(),
                        user: 'Admin',
                      )),
              (Route<dynamic> route) => false);
        }
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Form(
        key: _formKey,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(24),
                child: TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: 1, color: Colors.red), //<-- SEE HERE
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: 3, color: Colors.red), //<-- SEE HERE
                    ),
                    labelText: 'Name',
                    labelStyle: TextStyle(
                        fontSize: 20.0, color: Color.fromARGB(255, 2, 157, 7)),
                    hintText: 'Enter Name',
                    hintStyle: TextStyle(
                        fontSize: 20.0,
                        color: Color.fromARGB(255, 39, 126, 197)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: 1, color: Colors.red), //<-- SEE HERE
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: 3, color: Colors.red), //<-- SEE HERE
                    ),
                    labelText: 'Email',
                    labelStyle: TextStyle(
                        fontSize: 20.0, color: Color.fromARGB(255, 2, 157, 7)),
                    hintText: 'Enter Email',
                    hintStyle: TextStyle(
                        fontSize: 20.0,
                        color: Color.fromARGB(255, 39, 126, 197)),
                  ),
                  validator: (value) {
                    final bool isValid = EmailValidator.validate(value!);
                    print(isValid);

                    if (value == null || value.isEmpty || isValid == false)
                      return 'Please enter valid email';

                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: 1, color: Colors.red), //<-- SEE HERE
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: 3, color: Colors.red), //<-- SEE HERE
                    ),
                    labelText: 'Password',
                    labelStyle: TextStyle(
                        fontSize: 20.0, color: Color.fromARGB(255, 2, 157, 7)),
                    hintText: 'Enter Password',
                    hintStyle: TextStyle(
                        fontSize: 20.0,
                        color: Color.fromARGB(255, 39, 126, 197)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  EasyLoading.show(status: 'loading...');
                  if (_formKey.currentState!.validate()) {
                    if (_nameController.text.toString().toLowerCase() ==
                            'admin' &&
                        _emailController.text.toString() == 'admin@gmail.com' &&
                        _passwordController.text.toString() == '123456') {
                      sharedPreference = await SharedPreferences.getInstance();
                      SharePreferencesStore.setPreference(
                          sharedPreference, true);
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => HomePageAdmin(
                                    // title: _nameController.text
                                    //     .toString()
                                    //     .toLowerCase(),
                                    // email: _emailController.text.toString(),
                                    user: 'admin',
                                  )),
                          (Route<dynamic> route) => false);
                    } else {
                      bool? isSignedIn = await firebaseAuthentication(
                          _nameController.text.toString().toLowerCase(),
                          _emailController.text.toString(),
                          _passwordController.text.toString());

                      if (isSignedIn!) {
                        EasyLoading.showSuccess('Success!');
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text("Login Successfull"),
                          backgroundColor: Colors.green,
                        ));

                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => HomePageUser(
                                      // title: _nameController.text
                                      //     .toString()
                                      //     .toLowerCase(),
                                      // email: _emailController.text.toString(),
                                      user: user!,
                                    )),
                            (Route<dynamic> route) => false);
                      } else {
                        EasyLoading.showError('Failed with Error');
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text("Login Failed"),
                          backgroundColor: Colors.red,
                        ));
                      }
                    }
                  }
                  EasyLoading.dismiss();
                },
                style: ElevatedButton.styleFrom(
                  elevation: 20,
                  onPrimary: Colors.black87,
                  primary: Colors.grey[300],
                  minimumSize: const Size(88, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                  ),
                ),
                child: const Text('Join'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
