import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:graphico/screen/account_screen.dart';
import './profile_screen.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({Key? key}) : super(key: key);

  @override
  _VerifyScreenState createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  Timer timer = Timer.periodic(Duration(seconds: 3), (timer) {});
  bool _isUserEmailVerified = false;
  bool _isAcoountScreen = false;
  @override
  void initState() {
    super.initState();
    user!.sendEmailVerification();
    Future(() async {
      timer = Timer.periodic(Duration(seconds: 5), (timer) async {
        await FirebaseAuth.instance.currentUser?.reload();
        var user = FirebaseAuth.instance.currentUser;
        if (user?.emailVerified ?? false) {
          timer.cancel();
          setState(() {
            _isAcoountScreen = true;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return _isAcoountScreen
        ? AccountScreen()
        : Column(
            children: [
              Center(
                child: _isUserEmailVerified
                    ? Text('Eamil Verified')
                    : Text(
                        'An email has been sent to ${user!.email}, please verify it'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).accentColor,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(30),
                    ),
                  ),
                ),
                onPressed: () async {
                  await user!.delete();
                  setState(() {
                    _isAcoountScreen = true;
                  });
                },
                child: Text('Cancel'),
              ),
            ],
          );
  }
}
