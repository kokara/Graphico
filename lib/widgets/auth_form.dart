import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthForm extends StatefulWidget {
  final void Function(String email, String password, String usernaeme,
      bool isLogin, BuildContext ctx) submitFn;
  bool _isLoading;
  AuthForm(this.submitFn, this._isLoading);

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  var _isLogin = true;
  var _isForgotPassword = false;
  String _userEmail = '';
  String _userName = '';
  String _userPassword = '';
  FocusNode _focusNode1 = FocusNode();
  FocusNode _focusNode2 = FocusNode();
  FocusNode _focusNode3 = FocusNode();
  void _trySubmit() {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState!.save();
      widget.submitFn(_userEmail.trim(), _userPassword.trim(), _userName.trim(),
          _isLogin, context);
    }
  }

  @override
  void initState() {
    super.initState();

    _focusNode1 = FocusNode();
    _focusNode2 = FocusNode();
    _focusNode3 = FocusNode();
  }

  @override
  void dispose() {
    _focusNode1.dispose();
    _focusNode2.dispose();
    _focusNode3.dispose();

    super.dispose();
  }

  void _requestFocus(FocusNode focusNode) {
    setState(() {
      FocusScope.of(context).requestFocus(focusNode);
    });
  }

  Future<void> _sendEmail() async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: _userEmail);
  }

  Future<void> _showMyDialog() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (isValid) {
      _formKey.currentState!.save();
      print(_userEmail);
      await _sendEmail();
      return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text(
                'A password email has been sent to $_userEmail',
                textAlign: TextAlign.center,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(primary: Colors.grey),
                  child: Text(
                    'Ok',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    key: ValueKey('email'),
                    focusNode: _focusNode1,
                    onTap: () {
                      _requestFocus(_focusNode1);
                    },
                    cursorColor: Theme.of(context).accentColor,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Theme.of(context).accentColor)),
                      labelText: 'Email address',
                      labelStyle: TextStyle(
                          color: _focusNode1.hasFocus
                              ? Theme.of(context).accentColor
                              : Colors.grey),
                    ),
                    validator: (value) {
                      if (value!.isEmpty || !value.contains('@'))
                        return 'Please enter a valid email address ';
                      else
                        return null;
                    },
                    onSaved: (value) {
                      print(value);
                      _userEmail = value.toString();
                    },
                  ),
                  if (_isForgotPassword)
                    SizedBox(
                      height: 10,
                    ),
                  if (_isForgotPassword)
                    ElevatedButton(
                      onPressed: () {
                        _showMyDialog();
                      },
                      child: Text('Submit'),
                      style: ElevatedButton.styleFrom(
                        primary: Theme.of(context).accentColor,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                        ),
                      ),
                    ),
                  if (_isForgotPassword)
                    TextButton(
                      onPressed: () {
                        setState(
                          () {
                            _isLogin = true;
                            _isForgotPassword = false;
                          },
                        );
                      },
                      style: TextButton.styleFrom(primary: Colors.grey),
                      child: Text(
                        'Return to Sign In',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  if (!_isLogin && !_isForgotPassword)
                    TextFormField(
                      key: ValueKey('username'),
                      focusNode: _focusNode2,
                      onTap: () {
                        _requestFocus(_focusNode2);
                      },
                      cursorColor: Theme.of(context).accentColor,
                      validator: (value) {
                        if (value!.isEmpty || value.length < 4)
                          return 'Please enter at least 4 characters';
                        else
                          return null;
                      },
                      decoration: InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Theme.of(context).accentColor),
                        ),
                        labelStyle: TextStyle(
                            color: _focusNode2.hasFocus
                                ? Theme.of(context).accentColor
                                : Colors.grey),
                        labelText: 'Username',
                      ),
                      onSaved: (value) {
                        _userName = value.toString();
                      },
                    ),
                  if (!_isForgotPassword)
                    TextFormField(
                      key: ValueKey('password'),
                      focusNode: _focusNode3,
                      onTap: () {
                        _requestFocus(_focusNode3);
                      },
                      cursorColor: Theme.of(context).accentColor,
                      validator: (value) {
                        if (value!.isEmpty || value.length < 7)
                          return 'Password must be at least 7 characters long ';
                        else
                          return null;
                      },
                      decoration: InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Theme.of(context).accentColor),
                        ),
                        labelStyle: TextStyle(
                            color: _focusNode3.hasFocus
                                ? Theme.of(context).accentColor
                                : Colors.grey),
                        labelText: 'Password',
                      ),
                      obscureText: true,
                      onSaved: (value) {
                        _userPassword = value.toString();
                      },
                    ),
                  SizedBox(
                    height: 8,
                  ),
                  if (_isLogin)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isForgotPassword = true;
                              _isLogin = false;
                            });
                          },
                          style: TextButton.styleFrom(primary: Colors.grey),
                          child: Text(
                            'Forgot Password',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  if (widget._isLoading) CircularProgressIndicator(),
                  if (!widget._isLoading && !_isForgotPassword)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Theme.of(context).accentColor,
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)))),
                      onPressed: _trySubmit,
                      child: Text(_isLogin ? 'Login' : 'Signup'),
                    ),
                  if (!widget._isLoading && !_isForgotPassword)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                        });
                      },
                      style: TextButton.styleFrom(primary: Colors.grey),
                      child: Text(
                        _isLogin
                            ? 'Create new account'
                            : 'I already have an account',
                        style: TextStyle(color: Theme.of(context).accentColor),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
