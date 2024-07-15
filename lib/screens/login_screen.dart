import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:note_app/constants/toast.dart';
import 'package:note_app/controller/firebase/firebaseManager.dart';
import 'package:note_app/screens/home.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Login',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 25)),
            const SizedBox(
              height: 30,
            ),
            TextField(
              controller: emailController,
              style: const TextStyle(fontSize: 16, color: Colors.white),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                hintText: "@example.com",
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: const Icon(
                  Icons.email,
                  color: Colors.grey,
                ),
                fillColor: Colors.grey.shade800,
                filled: true,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              style: const TextStyle(fontSize: 16, color: Colors.white),
              obscureText: true,
              obscuringCharacter: '*',
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                hintText: "Password",
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: const Icon(
                  Icons.password,
                  color: Colors.grey,
                ),
                fillColor: Colors.grey.shade800,
                filled: true,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
              ),
            ),
            SizedBox(height: 20),
            isLoading
                ? Center(
                    child: CircularProgressIndicator.adaptive(),
                  )
                : Container(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isLoading = true;
                        });
                        if (emailController.text.isEmpty) {
                          ToastUtil.showErrorToast("Please Enter Email");
                        } else if (passwordController.text.isEmpty) {
                          ToastUtil.showErrorToast("Please Enter Password");
                        } else {
                          AuthService authService = AuthService();
                          authService
                              .signInWithEmailAndPassword(
                                  emailController.text, passwordController.text)
                              .then((loggedInUser) {
                            if (loggedInUser != null) {
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  CupertinoDialogRoute(
                                      builder: (_) => HomeScreen(
                                            email: emailController.text,
                                            password: passwordController.text,
                                          ),
                                      context: context),
                                  (route) => false);
                            }
                          });
                        }
                        setState(() {
                          isLoading = false;
                        });
                      },
                      child: Text(
                        'Submitted',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                    ),
                  ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "If you have not Account then, ",
                  style: TextStyle(color: Colors.white),
                ),
                TextButton(
                    onPressed: () {},
                    child: const Text(
                      "SignUp",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.green),
                    ))
              ],
            )
          ],
        ),
      ),
    );
  }
}
