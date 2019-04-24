import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'prompt_page.dart';

class AddSession extends StatefulWidget{
  AddSession(this.myPhone,this.myName);
  final String myPhone;
  final String myName;

  @override
  State createState() => new _AddSessionState(myPhone,myName);
}

class _AddSessionState extends State<AddSession>{
  _AddSessionState(this._myPhone,this._myName);
  String _myPhone;
  String _myName;

  final userReference = FirebaseDatabase.instance.reference().child('users');
  final chatReference = FirebaseDatabase.instance.reference().child('chats');
  String _searchUsername = "";
  String _searchPhone = "";

  final TextEditingController _phoneController = new TextEditingController();

 // PromptPage promptPage;

  Future<int> _findUser(String phone) async{
    return await userReference.child(phone).once().then((DataSnapshot onValue){
      if(onValue.value == null){
        _searchUsername = "";
        _searchPhone = "";
        return 0;
      }
      else{
        _searchPhone = onValue.value["phone"];
        _searchUsername = onValue.value["name"];
        return 1;
      }
    });
  }

  void _handleFind(){
    FocusScope.of(context).requestFocus(new FocusNode());
    if(_phoneController.text.isEmpty){
      showMessage(context, "Phone number cannot be empty");
      return;
    }
    else if(_phoneController.text.trim() == _myPhone){
      showMessage(context, "This is your phone number");
      return;
    }
    else if(_phoneController.text.trim().length < 7 || _phoneController.text.trim().length > 12){
      showMessage(context, "Format is not correct");
      return;
    }
    showDialog<int>(
      context: context,
      barrierDismissible: false,
      child: new ShowAwait(_findUser(_phoneController.text))
    ).then((int onValue){
      if(onValue == 0){
        showMessage(context, "Cannot find the account");
        setState(() {

        });
      }
      else if(onValue == 1){
        setState(() {

        });
      }
    });
  }

  Future<int> _addSession() async{
    String _time = new DateTime.now().toString();
    return await chatReference.child('$_myPhone/$_searchPhone').once().then((DataSnapshot onValue){
      if (onValue.value == null){
        chatReference.child('$_myPhone/$_searchPhone').set({
          "name": _searchUsername,
          "phone": _searchPhone,
          "messages": "$_myPhone$_searchPhone",
          "lastMessage": "我们已经是好友了，一起来聊天吧！",
          "timestamp": _time,
          "active": "true"
        });
        chatReference.child('$_searchPhone/$_myPhone').set({
          "name": widget.myName,
          "phone": _myPhone,
          "messages": "$_myPhone$_searchPhone",
          "lastMessage": "我们已经是好友了，一起来聊天吧！",
          "timestamp": _time,
          "active": "true"
        });
        return 1;
      }
      else if(onValue.value["active"] == "true"){
        print("跳转到对应聊天窗口");
        return 0;
      }
      else{
        print("重新添加好友并移除以前的记录");
        return 2;
      }
    });
  }

  void _handleAppend(){
    showDialog<int>(
      context: context,
      barrierDismissible: false,
      child: new ShowAwait(_addSession())
    ).then((int onValue){
      if(onValue == 1){
        print("好友添加成功");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new SimpleDialog(
      title: new Text("new friend"),
      children: <Widget>[
        new Container(
          margin: const EdgeInsets.symmetric(horizontal: 23.0),
          child: new Row(
            children: <Widget>[
              new Flexible(
                  child: new TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: new InputDecoration.collapsed(hintText: 'Input the phone number you want to chat'),
                  ),
              ),
              new IconButton(
                icon: new Icon(Icons.search),
                onPressed: (){
                  _handleFind();
                },
              )
            ],
          ),
        ),
        _searchUsername == "" ?
          new Text("") :
          new Container(
            margin: const EdgeInsets.symmetric(horizontal: 23.0),
            child: new Row(
              children: <Widget>[
                new CircleAvatar(
                  child: new Text(_searchUsername[0]),
                  backgroundColor: Theme.of(context).buttonColor,
                ),
                new Flexible(
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Text(
                        "   " + _searchUsername,
                        textScaleFactor: 1.2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      new Text(
                        "   " + _searchPhone,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        new Container(
          margin: const EdgeInsets.only(top: 18.0),
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              new RaisedButton(
                  onPressed: (){
                    Navigator.of(context).pop();
                  },
                  elevation: 0.0,
                  colorBrightness: Brightness.dark,
                  child: new Text("取消"),
              ),
              new RaisedButton(
                  onPressed: (){
                    if(_searchUsername != ""){
                      _handleAppend();
                    }
                  },
                  elevation: 0.0,
                  colorBrightness: _searchUsername == "" ? Brightness.light : Brightness.dark,
                  child: new Text("添加"),
              ),
            ],
          ),
        )
      ],
    );
  }
}