import 'package:flutter/material.dart';
import 'sign_in.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'group_chat_list.dart';

final ThemeData AndroidTheme = new ThemeData(
  primarySwatch: Colors.indigo,
  // primaryColor: Colors.grey[100],
);

void main() {
  _getLandingFile().then((onValue){
    runApp(new TalkcasuallyAPP(onValue.existsSync()));
  });
}

Future<File> _getLandingFile() async{
  String dir  = (await getApplicationDocumentsDirectory()).path;
  return new File('$dir/LandingInformation');
}

class TalkcasuallyAPP extends StatelessWidget {
  TalkcasuallyAPP(this.landing);
  final bool landing;

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'LightTalk',
        theme: AndroidTheme,
        home: landing ? new GroupChatList() : new SignIn()
    );
  }
}
