import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mini_projeto_5/services/authService.dart';

class SignInLogicScreen extends StatefulWidget {
  const SignInLogicScreen({super.key});

  @override
  State<SignInLogicScreen> createState() => _SignInLogicScreenState();
}

class _SignInLogicScreenState extends State<SignInLogicScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      AuthServices.checkAuthAndRegister(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blue[800],
        body: const Center(
          child: CircularProgressIndicator(),
        ));
  }
}
