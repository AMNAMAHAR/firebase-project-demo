import 'package:delivery/pages/login.dart';
import 'package:delivery/widget/widge_support.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'bottomnav.dart';
// Assuming you have a file named widge_support.dart

class SignUp extends StatefulWidget {
  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String email = "";
  String password = "";
  String name = "";

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  registration() async {
    if (_formKey.currentState!.validate()) {
      email = emailController.text;
      password = passwordController.text;
      name = nameController.text;

      try {
        final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,

        );
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.redAccent,
            content: Text("Registered Successfully",style: TextStyle(fontSize: 20),)));
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BottomNav(),));

        // You can use 'name' here if you're storing it in Firebase Auth user metadata.
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          print('The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          print('The account already exists for that email.');
        }
      } catch (e) {
        print(e);
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
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 2.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFff5c30),
                      Color(0xFFe74b1a),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: MediaQuery.of(context).size.height / 3),
                height: MediaQuery.of(context).size.height / 2,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Text(""),
              ),
              Container(
                margin: EdgeInsets.only(top: 60.0, left: 20.0, right: 20.0),
                child: Column(
                  children: [
                    Center(
                      child: Image.asset(
                        "images/logo.png",
                        width: MediaQuery.of(context).size.width / 1.5,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 50.0),
                    Material(
                      elevation: 5.0,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: EdgeInsets.only(left: 20.0, right: 20.0),
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height / 1.8,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              SizedBox(height: 30.0),
                              Text(
                                "Sign up",
                                style: AppWidget.HeadlineTextFeildStyle(),
                              ),
                              SizedBox(height: 30.0),
                              TextFormField(
                                controller: nameController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your name';
                                  }
                                  return null;
                                },
                                onChanged: (value) => name = value,
                                decoration: InputDecoration(
                                  hintText: 'Name',
                                  hintStyle: AppWidget.semiBoldTextFeildStyle(),
                                  prefixIcon: Icon(Icons.person_outlined),
                                ),
                              ),
                              SizedBox(height: 30.0),
                              TextFormField(
                                controller: emailController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter an email';
                                  }
                                  // Add more email validation logic if needed
                                  return null;
                                },
                                onChanged: (value) => email = value,
                                decoration: InputDecoration(
                                  hintText: 'Email',
                                  hintStyle: AppWidget.semiBoldTextFeildStyle(),
                                  prefixIcon: Icon(Icons.email_outlined),
                                ),
                              ),
                              SizedBox(height: 30.0),
                              TextFormField(
                                controller: passwordController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a password';
                                  }
                                  // Add more password validation logic if needed
                                  return null;
                                },
                                onChanged: (value) => password = value,
                                obscureText: true,
                                decoration: InputDecoration(
                                  hintText: 'Password',
                                  hintStyle: AppWidget.semiBoldTextFeildStyle(),
                                  prefixIcon: Icon(Icons.password_outlined),
                                ),
                              ),
                              SizedBox(height: 50.0),
                              GestureDetector(
                                onTap: ()async{
                                  if(_formKey.currentState!.validate()){
                                    setState(() {
                                      email=emailController.text;
                                      password=passwordController.text;
                                      name=nameController.text;
        
                                    });
        
                                  }
                                  registration();
        
                                },
                                child: Material(
                                  elevation: 5.0,
                                  borderRadius: BorderRadius.circular(20),
                                  child: InkWell(
                                    onTap: registration,
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(vertical: 8.0),
                                      width: 200,
                                      decoration: BoxDecoration(
                                        color: Color(0Xffff5722),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "SIGN UP",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18.0,
                                            fontFamily: 'Poppins1',
                                            fontWeight: FontWeight.bold,
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
                    ),
                    SizedBox(height: 70.0),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => LogIn()));
                      },
                      child: Text(
                        "Already have an account? Login",
                        style: AppWidget.semiBoldTextFeildStyle(),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
