import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chattappe/pages/service/database.dart';
import 'package:chattappe/pages/service/shared_prefi.dart';
import 'package:chattappe/pages/home.dart';

import 'signin.dart'; // Import your sign-in screen

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController mailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  Future<void> registration() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: mailController.text.trim(),
          password: passwordController.text.trim(),
        );

        String userId = userCredential.user!.uid;
        String userName = nameController.text.trim();
        String userEmail = mailController.text.trim();

        String searchKey = userName.substring(0, 1).toUpperCase();
        String userDisplayName = userName.split(' ')[0]; // Assuming first name is used as display name

        Map<String, dynamic> userInfoMap = {
          "Name": userName,
          "E-mail": userEmail,
          "username": userDisplayName,
          "SearchKey": searchKey,
          "photo": "https://firebasestorage.googleapis.com/v0/b/barberapp-ebcc1.appspot.com/o/icon1.png?alt=media&token=0fad24a5-a01b-4d67-b4a0-676fbc75b34a",
          "Id": userId,
        };

        await DatabaseMethods().addUserDetails(userInfoMap, userId);

        await SharedPreferenceHelper().saveUserId(userId);
        await SharedPreferenceHelper().saveUserDisplayName(userDisplayName);
        await SharedPreferenceHelper().saveUserEmail(userEmail);
        await SharedPreferenceHelper().saveUserPic(userInfoMap["photo"]);
        await SharedPreferenceHelper().saveUserName(userName.toUpperCase());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Registered Successfully",
              style: TextStyle(fontSize: 20.0),
            ),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
      } on FirebaseAuthException catch (e) {
        String errorMessage = "An error occurred. Please try again.";

        if (e.code == 'weak-password') {
          errorMessage = "Password provided is too weak.";
        } else if (e.code == 'email-already-in-use') {
          errorMessage = "The email address is already in use.";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              errorMessage,
              style: TextStyle(fontSize: 18.0),
            ),
          ),
        );
      } catch (e) {
        print('Error occurred: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          child: Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height / 4.0,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF7f30fe), Color(0xFF6380fb)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.elliptical(
                      MediaQuery.of(context).size.width,
                      105.0,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Center(
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          "Create a new Account",
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFFbbb0ff),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        margin: EdgeInsets.symmetric(
                          vertical: 20.0,
                          horizontal: 20.0,
                        ),
                        child: Material(
                          elevation: 5.0,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 20.0,
                              horizontal: 30.0,
                            ),
                            height: MediaQuery.of(context).size.height / 1.6,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Name",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18.0,
                                  ),
                                ),
                                SizedBox(height: 10.0),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 1.0,
                                      color: Colors.black38,
                                    ),
                                  ),
                                  child: TextFormField(
                                    controller: nameController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please Enter Name';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      prefixIcon: Icon(
                                        Icons.mail_outline,
                                        color: Color(0xFFbbb0ff),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "Email",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18.0,
                                  ),
                                ),
                                SizedBox(height: 10.0),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 1.0,
                                      color: Colors.black38,
                                    ),
                                  ),
                                  child: TextFormField(
                                    controller: mailController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please Enter Email';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      prefixIcon: Icon(
                                        Icons.person,
                                        color: Color(0xFFbbb0ff),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "Password",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18.0,
                                  ),
                                ),
                                SizedBox(height: 10.0),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 1.0,
                                      color: Colors.black38,
                                    ),
                                  ),
                                  child: TextFormField(
                                    controller: passwordController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please Enter Password';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      prefixIcon: Icon(
                                        Icons.password,
                                        color: Color(0xFFbbb0ff),
                                      ),
                                    ),
                                    obscureText: true,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "Confirm Password",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18.0,
                                  ),
                                ),
                                SizedBox(height: 10.0),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 1.0,
                                      color: Colors.black38,
                                    ),
                                  ),
                                  child: TextFormField(
                                    controller: confirmPasswordController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please Enter Confirm password';
                                      }
                                      if (value != passwordController.text) {
                                        return 'Passwords do not match';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      prefixIcon: Icon(
                                        Icons.password,
                                        color: Color(0xFFbbb0ff),
                                      ),
                                    ),
                                    obscureText: true,
                                  ),
                                ),
                                SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Already have an account?",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14.0, // Increase font size for readability
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        // Navigate to sign-in screen
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(builder: (context) => SignIn()),
                                        );
                                      },
                                      child: Text(
                                        " Sign In Now!",
                                        style: TextStyle(
                                          color: Color(0xFFbbb0ff),
                                          fontSize: 14.0, // Increase font size for readability
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.0),
                      GestureDetector(
                        onTap: registration,
                        child: Center(
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 20.0),
                            width: MediaQuery.of(context).size.width,
                            child: Material(
                              elevation: 5.0,
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Color(0xFF6380fb),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    "SIGN UP",
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
