import 'package:flutter/material.dart';
import 'sign_up.dart';
import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'prompt_page.dart';
import 'group_chat_list.dart';

class SignIn extends StatefulWidget{
  @override
  State createState() => new SignInState();
}

class SignInState extends State<SignIn>{
  final TextEditingController _phoneController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();

  bool _correctPhone = true;
  bool _correctPassword = true;
  PromptPage promptPage = new PromptPage();

  final reference = FirebaseDatabase.instance.reference().child('users');

  static final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Future<Null> _saveLogin(String phone, String password, String name, String email) async{
    String dir = (await getApplicationDocumentsDirectory()).path;
    await new File('$dir/LandingInformation').writeAsString(
      '{"phone":"$phone","name":"$name","email":"$email"}'
    );
  }

  void _checkInput(){
    if(_phoneController.text.isNotEmpty && (_phoneController.text.trim().length < 7 ||
    _phoneController.text.trim().length > 12)){
      _correctPhone = false;
    }
    else{
      _correctPhone = true;
    }
    if(_passwordController.text.isNotEmpty && (_passwordController.text.trim().length < 6)){
      _correctPassword = false;
    }
    else{
      _correctPassword = true;
    }
    setState(() {

    });
  }

  Future<int> _userLogIn(String phone, String password) async{
    return await reference.child(_phoneController.text).once().then((DataSnapshot onValue){
      if(onValue.value == null){
        return 0;
      }
      if(onValue.value["password"] == _passwordController.text){
        _saveLogin(onValue.value["phone"], onValue.value["password"], onValue.value["name"], onValue.value["email"]);
        return 2;
      }
      else{
        return 1;
      }
    });
  }

  void _handleSubmitted(){
    FocusScope.of(context).requestFocus(new FocusNode());
    _checkInput();
    if(_passwordController.text == "" || _phoneController.text == ""){
      promptPage.showMessage(context, "Information for logging in is not complete!");
      return;
    }
    else if(!_correctPassword || !_correctPhone){
      promptPage.showMessage(context, "Inputing format is not correct!");
      return;
    }
    showDialog<int>(
      context: context,
      barrierDismissible: false,
      child: new ShowAwait(_userLogIn(_phoneController.text, _passwordController.text))
    ).then((int onValue){
      if(onValue == 0){
        promptPage.showMessage(context, "UID has not been registered!");
      }
      else if(onValue == 1){
        promptPage.showMessage(context, "Wrong password!");
      }
      else{
        Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context){
          return new GroupChatList();
        }));
      }
    });
  }

  void _openSighUp(){
    setState(() {
      Navigator.of(context).push(new MaterialPageRoute<List<String>>(
        builder: (BuildContext context){
          return new SignUp();
        },
      )).then((onValue){
        if(onValue != null){
          _phoneController.text = onValue[0];
          _passwordController.text = onValue[1];
          FocusScope.of(context).requestFocus(new FocusNode());
          _scaffoldKey.currentState.showSnackBar(new SnackBar(
              content: new Text("注册成功")));
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      key: _scaffoldKey,
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
                          image: new ExactAssetImage('images/sign_in_background.jpg'),
                          fit: BoxFit.cover
                      ),
                    ),
                  )
              )
          ),
          new Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Center(
                child: new Image.asset('images/talk_casually(1).png'
                  ,width: MediaQuery.of(context).size.width * 0.4,
                ),
              ),
              new Container(
                width: MediaQuery.of(context).size.width * 0.96,
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new TextField(
                      controller: _phoneController,
                      decoration: new InputDecoration(
                        hintText: 'Uid',
                        //helperText: 'Your phone number',
                        errorText: _correctPhone ?
                          null : 'Length of Uid should be 7 to 12 bits',
                        icon: new Icon(
                          Icons.account_circle,
                        )
                      ),
                      onSubmitted: (value){
                        _checkInput();
                      },
                    ),
                    new TextField(
                      controller: _passwordController,
                      decoration: new InputDecoration(
                        hintText: 'Password',
                        //helperText: 'Password of your Uid',
                        errorText: _correctPassword ?
                          null : 'Length should be at least 6 bits',
                        icon: new Icon(
                          Icons.lock_outline,
                        )
                      ),
                      onSubmitted: (value){
                        _checkInput();
                      },
                    )
                  ],
                ),
              ),
              new FlatButton(
                  //padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
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
                          "Sign In",
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
                    onPressed: _openSighUp,
                    child: new Text(
                        "Don't have an account? Sign up",
                        style: new TextStyle(
                          color:const Color(0xff000000),
                        ),

                    ),

                ),
              )
            ],
          )
        ]
      )
    );
  }

}