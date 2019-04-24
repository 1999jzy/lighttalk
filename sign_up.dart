import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'prompt_page.dart';
import 'dart:async';

class SignUp extends StatefulWidget{
  @override
  State createState() => new SignUpState();
}

class SignUpState extends State<SignUp>{
  final TextEditingController _usernameController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();
  final TextEditingController _emailController = new TextEditingController();
  final TextEditingController _phoneController = new TextEditingController();

  final reference = FirebaseDatabase.instance.reference().child('users');

  bool _correctUsername = true;
  bool _correctPassword = true;
  bool _correctPhone = true;

  PromptPage promptPage = new PromptPage();

  Future _handleSubmitted() async{
    FocusScope.of(context).requestFocus(new FocusNode());
    _checkInput();

    if(_usernameController.text == "" || _passwordController.text == "" || _phoneController.text == ""){
      await promptPage.showMessage(context, "Username or passwaord or phone number cannot be empty");
      return;
    }
    if(!_correctPassword || !_correctUsername || !_correctPhone){
      await promptPage.showMessage(context, "Username or password format is not correct");
      return;
    }
    showDialog<int>(
      context: context,
      barrierDismissible: false,
      child:
        new ShowAwait(_userRegister(
            _usernameController.text, _passwordController.text,
            _emailController.text, _phoneController.text))).then((int onValue) {
              if (onValue == 0) {
              promptPage.showMessage(context, "This UID has been registered!");
              }
              else if (onValue == 1) {
                Navigator
                    .of(context)
                    .pop([_phoneController.text, _passwordController.text]);
              }
            });
  }

  void _checkInput(){
    if(_phoneController.text.isNotEmpty && (_phoneController.text.trim().length < 7 ||
    _phoneController.text.trim().length > 12)){
      _correctPhone = false;
    }
    else{
      _correctPhone = true;
    }
    if(_usernameController.text.isNotEmpty && (_usernameController.text.trim().length < 2)){
      _correctUsername = false;
    }
    else{
      _correctUsername = true;
    }
    if(_passwordController.text.isNotEmpty && _passwordController.text.trim().length < 6){
      _correctPassword = false;
    }
    else{
      _correctPassword = true;
    }
  }

  Future<int> _userRegister(String username,String password,String email,String phone) async{
    return await reference.child(_phoneController.text).once().then((DataSnapshot onValue){
      if(onValue.value == null){
        reference.child(phone).set({
          'name': username,
          'password': password,
          'email': email,
          'phone': phone,
        });
        return 1;
      }
      else{
        return 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      body: new Stack(
        children: <Widget>[
          new Opacity(
              opacity: 0.3,
              child: new GestureDetector(
                onTap: (){
                  FocusScope.of(context).requestFocus(new FocusNode());
                  _checkInput();
                },
                child: new Container(
                  decoration: new BoxDecoration(
                    image: new DecorationImage(
                        image: new ExactAssetImage('images/sign_up_background.jpg'),
                        fit: BoxFit.cover
                    )
                  ),
                ),
              ),
          ),
          new Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new BackButton(),
              new Text(
                'Sign Up',
                textScaleFactor: 2.0,
                style: TextStyle(
                  color: const Color(0xff000000),
                ),
              ),
              new Container(
                width: MediaQuery.of(context).size.width * 0.96,
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new TextField(
                      controller: _usernameController,
                      decoration: new InputDecoration(
                        helperText: 'Your username',
                        hintText: 'Username',
                        errorText: _correctUsername ?
                          null : 'Length of username is at least 3 bits',
                        icon: new Icon(Icons.account_circle),
                      ),
                      onSubmitted: (value){
                        _checkInput();
                      },
                    ),
                    new TextField(
                      controller: _passwordController,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      decoration: new InputDecoration(
                        hintText: 'Password',
                        helperText: 'The password of logging and registering',
                        errorText: _correctPassword ?
                          null : 'Length of password is at least 6 bits',
                        icon: new Icon(Icons.lock_outline),
                      ),
                      onSubmitted: (value){
                        _checkInput();
                      },
                    ),
                    new TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: new InputDecoration(
                        helperText: 'Helpful to connect with you',
                        hintText: 'E-mail',
                        icon: new Icon(Icons.email),
                      ),
                      onSubmitted: (value){
                        _checkInput();
                      },
                    ),
                    new TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: new InputDecoration(
                        helperText: 'Unique ID',
                        hintText: 'Phone',
                        errorText: _correctPhone ?
                          null: 'Length of phonenumber is 7 to 12 bits',
                        icon: new Icon(Icons.phone),
                      ),
                      onSubmitted: (value){
                        _checkInput();
                      },
                    ),
                  ],
                ),
              ),
              new FlatButton(
                  onPressed: (){
                    _handleSubmitted();
                  },
                  child: new Container(
                    decoration: new BoxDecoration(
                      color: Theme.of(context).accentColor,
                    ),
                    child: new Center(
                      child: new Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                        child: new Text(
                          "Join",
                          style: new TextStyle(
                              color: const Color(0xff000000),
                              fontSize: 20.0
                          ),
                        ),
                      ),
                    ),
                  )
              ),
              new Center(
                child: new FlatButton(
                    onPressed: (){
                      Navigator.of(context).pop();
                    },
                    child: new Text(
                      'Already have an account ? Sign in',
                      style: new TextStyle(
                        color: const Color(0xff000000),
                      ),
                    )
                ),
              )
            ],
          )
        ],
      )
    );
  }

}
