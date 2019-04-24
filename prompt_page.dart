import 'dart:async';
import 'package:flutter/material.dart';


class PromptPage{
  showMessage(BuildContext context,String text){
    showDialog<Null>(
      context: context,
      child: new AlertDialog(
        title: new Text("Warning!"),
        content: new Text(text),
        actions: <Widget>[
          new FlatButton(
              onPressed: (){
                Navigator.pop(context);
              },
              child: const Text('OK'))
        ],
      )
    );
  }
}

showMessage(BuildContext context,String text){
  showDialog<Null>(
      context: context,
      child: new AlertDialog(
        title: new Text("Warning!"),
        content: new Text(text),
        actions: <Widget>[
          new FlatButton(
              onPressed: (){
                Navigator.pop(context);
              },
              child: const Text('OK'))
        ],
      )
  );
}

String ReadableTime(String timestamp) {
  List<String> timeList = timestamp.split(" ");
  List<String> times = timeList[1].split(":");
  String time;
  if (new DateTime.now().toString().split(" ")[0] == timeList[0]) {
    if (int.parse(times[0]) < 6) {
      time = "凌晨${times[0]}:${times[1]}";
    } else if (int.parse(times[0]) < 12) {
      time = "上午${times[0]}:${times[1]}";
    } else if (int.parse(times[0]) == 12) {
      time = "中午${times[0]}:${times[1]}";
    } else {
      time =
      "下午${(int.parse(times[0])- 12).toString().padLeft(2,'0')}:${times[1]}";
    }
  } else {
    time = timeList[0];
  }
  return time;
}


class ShowAwait extends StatefulWidget{
  ShowAwait(this.requestCallback);
  final Future<int> requestCallback;

  @override
  _ShowAwaitState createState() => new _ShowAwaitState();
}

class _ShowAwaitState extends State<ShowAwait>{
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    new Timer(new Duration(seconds: 2),(){
      widget.requestCallback.then((int onValue){
        Navigator.of(context).pop(onValue);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Center(
      child: new CircularProgressIndicator(),
    );
  }
}