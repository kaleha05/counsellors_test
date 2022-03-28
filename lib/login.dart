import 'package:another_flushbar/flushbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rada_counsellors/home.dart';
import 'theme.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);


  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _passpasswordVisible = true;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;


  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool _showButton = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Form(
          autovalidateMode: AutovalidateMode.always,
          key: _formKey,
          child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 200, 10, 0),
              child: ListView(
                  children: <Widget>[

                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(10),
                      child: const Text(
                        'Log In',
                        style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Montserrat'),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            labelText: 'School Email',
                          ),
                          validator: MultiValidator([
                            RequiredValidator(errorText: "* Required"),
                            EmailValidator(errorText: "Enter valid email id"),
                          ])
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                      child: TextFormField(
                          obscureText: true,
                          controller: passwordController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            labelText: 'Password',
                          ),
                          validator: MultiValidator([
                            RequiredValidator(errorText: "* Required"),
                            MinLengthValidator(6,
                                errorText: "Password should be atleast 6 characters"),
                            MaxLengthValidator(15,
                                errorText:
                                "Password should not be greater than 15 characters")
                          ])
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        //forgot password screen
                      },
                      child: const Text('Forgot Password',
                        style: TextStyle(color: Colors.black),),
                    ),
                    Container(
                      height: 50,
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: ElevatedButton(
                        child: const Text('Log In',
                            style: TextStyle(color: Colors.white,
                                fontFamily: 'Montserrat')),
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                    side: BorderSide(color: AppColours.black)
                                )
                            ),
                            backgroundColor: MaterialStateProperty.all(
                                Colors.black),
                            minimumSize: MaterialStateProperty.all(Size(60, 60))
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            signInUser(emailController.text.trim(),
                                passwordController.text.trim());
                            print("Validated");
                          } else {
                            print("Not Validated");
                          }
                        },
                      ),

                    )
                  ]
              )
          ),
        )
    );
  }

  Future<void> signInUser(String email, String password) async {
    try {
      var result = await _firebaseAuth.signInWithEmailAndPassword(
          email: email.trim(), password: password.trim());
      var user = result.user;

      if (user != null && user.emailVerified) {
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CounsellorsHome()),
        );
      }
    }
    on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        Flushbar(
          title: "Login Failed",
          message: "User does not exist",
          icon: Icon(
            Icons.error_outline,
            color: Colors.white,
            size: 30,
          ),
          duration: Duration(seconds: 3),
          isDismissible: false,
        )
          ..show(context);
      }
      else if (e.code == "user-disabled"){
        Flushbar(
          title: "Login Failed",
          message: "User has been disabled",
          icon: Icon(
            Icons.error_outline,
            color: Colors.white,
            size: 30,
          ),
          duration: Duration(seconds: 3),
          isDismissible: false,
        )
          ..show(context);
      }
      else if (e.code == "wrong-password") {
        Flushbar(
          title: "Login Failed",
          message: "You entered the wrong password",
          duration: Duration(seconds: 3),
          isDismissible: true,
          flushbarPosition: FlushbarPosition.TOP,
          icon: Icon(
            Icons.error_outline,
            color: Colors.white,
            size: 30,
          ),
          backgroundColor: Colors.redAccent,
        )
          ..show(context);

      }
      else if (e.code == "invalid-email") {
        Flushbar(
          title: "Login Failed",
          message: "You entered an invalid email",
          duration: Duration(seconds: 3),
          isDismissible: true,
          flushbarPosition: FlushbarPosition.TOP,
          icon: Icon(
            Icons.error_outline,
            color: Colors.white,
            size: 30,
          ),
          backgroundColor: Colors.redAccent,
        )
          ..show(context);

      }
    }

  }
}


