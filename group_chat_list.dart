import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'add_session.dart';
import 'group_chat_list_body.dart';

class GroupChatList extends StatefulWidget{
  @override
  State createState() => new _GroupChatListState();
}

class _GroupChatListState extends State<GroupChatList>{
  String name = "default";
  String phone = "default";
  String email = "default";

  Future<Map> _readLoginData() async{
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = new File('$dir/LandingInformation');
    String data = await file.readAsString();
    print(data);
    Map json = new JsonDecoder().convert(data);
    return json;
  }

  @override
  void initState(){
    super.initState();
    _readLoginData().then((Map onValue){
      setState(() {
        name = onValue["name"];
        phone = onValue["phone"];
        email = onValue["email"];
      });
    });
  }

  Widget _drawerOption(Icon icon, String name){
    return new Container(
      padding: const EdgeInsets.only(top: 19.0),
      child: new Row(children: <Widget>[
        new Container(
          padding: const EdgeInsets.only(right: 28.0),
          child: icon,
        ),
        new Text(name)
      ],),
    );
  }

  @override
  Widget build(BuildContext context) {
    Drawer drawer = new Drawer(
      child: new ListView(
        children: <Widget>[
          new DrawerHeader(
              child: new Column(
                children: <Widget>[
                  new GestureDetector(
                    onTap: (){

                    },
                    child: new Row(
                        children:<Widget>[
                          new Container(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: new CircleAvatar(
                              child: new Text(name[0]),
                            ),
                          ),
                          new Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              new Text(
                                name,
                                textScaleFactor: 2,
                              ),
                              new Text(
                                phone,
                                textScaleFactor: 1,
                              )
                            ],
                          ),
                       ],
                    ),
                  ),
                  _drawerOption(new Icon(Icons.account_circle), "个人资料"),
                  _drawerOption(new Icon(Icons.settings), "设置")
                ],
              )
          ),
        ],
      ),
    );
    // TODO: implement build
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("LightTalk"),
      ),
      drawer: drawer,
      body: new Center(
        child : phone == "default" ? new Text("ChatList") : new GroupChatListBody(phone: phone,myName: name,),
      ),
      floatingActionButton: new FloatingActionButton(
        backgroundColor: Colors.indigoAccent[200],
        elevation: 0.0,
        onPressed: (){
          showDialog<Null>(
            context: context,
            barrierDismissible: false,
            child: new AddSession(phone,name),
          );
        },
        child: new Icon(Icons.person_add),
      ),
    );
  }
}