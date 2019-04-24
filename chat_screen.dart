import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:math';
import 'dart:io';
import 'image_zoomable.dart';

//const String _name = "jzy";

GoogleSignInAccount _currentUser;

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);

final analytics = new FirebaseAnalytics();

final auth = FirebaseAuth.instance;

final ThemeData AndroidTheme = new ThemeData(
  primarySwatch: Colors.indigo,
  // primaryColor: Colors.grey[100],
);

bool auth_logged = false;

class ChatMessage extends StatelessWidget{
  ChatMessage({this.snapshot,this.animation});
  final DataSnapshot snapshot;
  final Animation animation;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new SizeTransition(
        sizeFactor: new CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut),
        axisAlignment: 0.0,
        child: new Container(
          margin: const EdgeInsets.symmetric(vertical: 10.0),
          child: new Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Container(
                margin: const EdgeInsets.only(right: 16.0),
//                child: _currentUser != null ?
//                new GoogleUserCircleAvatar(identity: _currentUser,
//                    placeholderPhotoUrl:snapshot.value['senderPhotoUrl'])
//                    :null,
                  child: new CircleAvatar(
                      child: new Text(snapshot.value['senderName'][0])
                  ),
              ),
              new Expanded(
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Text(snapshot.value['senderName'], style:Theme.of(context).textTheme.subhead),
                      new Container(
                        margin: const EdgeInsets.only(top:5.0),
                        child: snapshot.value['imageUrl'] != null ?
                        new GestureDetector(
                          onTap: (){
                            Navigator.of(context).push(new MaterialPageRoute<Null>(
                                builder: (BuildContext context){
                                  return new ImageZoomable(new NetworkImage(snapshot.value['imageUrl']),
                                    onTap:(){
                                      Navigator.of(context).pop();
                                    },
                                  );
                                }
                            )
                            );
                          },
                          child: new Image.network(
                            snapshot.value['imageUrl'],
                            width: 250.0,
                          ),
                        ):
                        new Text(snapshot.value['text']),
                      )
                    ],
                  ))
            ],
          ),
        )
    );
  }
}

class ChatScreen extends StatefulWidget{
  ChatScreen({this.messages,this.myName,this.sheName,this.myPhone,this.shePhone});
  final String messages;
  final String myName;
  final String sheName;
  final String myPhone;
  final String shePhone;

  @override
  State<StatefulWidget> createState() => ChatScreenState(messages);
}

class ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin{
  ChatScreenState(this._messages);
  final String _messages;

  final TextEditingController _textController = new TextEditingController();
  final chatReference = FirebaseDatabase.instance.reference().child('chats');
  final reference = FirebaseDatabase.instance.reference().child('messages');
  //final List<ChatMessage> _messages = <ChatMessage>[];
  bool _isComposing = false;

  static final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  

  Future<Null> _ensureLoggedIn() async{
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account)async{
      setState(() {
        _currentUser = account;
      });

    });
    if(_currentUser == null) {await _googleSignIn.signInSilently();}
    if(_currentUser == null) {
      await _googleSignIn.signIn();
      analytics.logLogin();
    }
    //print(auth.currentUser);
    if(auth_logged==false) {
      GoogleSignInAuthentication credentials = await _currentUser
          .authentication;
      await auth.signInWithGoogle(
          idToken: credentials.idToken, accessToken: credentials.accessToken);
      auth_logged = true;
    }
  }

  void _sendMessage({String text,String imageUrl}){
//    ChatMessage message = new ChatMessage(
//      text:text,
//      animationController: new AnimationController(
//          duration: new Duration(milliseconds: 700),
//          vsync: this
//      ),
//    );
//    setState(() {
//      _messages.insert(0, message);
//    });
//    message.animationController.forward();
    String time = new DateTime.now().toString();
    reference.child(_messages).push().set({
      'text': text,
      'imageUrl': imageUrl,
      'senderName': widget.myName,
      'timestamp': time,
    });
    if(text == null){
      text = "[图片]";
    }
    chatReference.child('${widget.shePhone}/${widget.myPhone}/lastMessage').set(text);
    chatReference.child('${widget.shePhone}/${widget.myPhone}/timestamp').set(time);
    chatReference.child('${widget.myPhone}/${widget.shePhone}/lastMessage').set(text);
    chatReference.child('${widget.myPhone}/${widget.shePhone}/timestamp').set(time);
//    analytics.logEvent(name: 'send_message');
  }

  Future _handleSubmit(String text) async{
    chatReference.child('${widget.myPhone}/${widget.shePhone}/active').onValue.listen((Event event){
      if(event.snapshot.value == "true"){
        _textController.clear();
        setState(() {
          _isComposing = false;
        });
        //await _ensureLoggedIn();
        _sendMessage(text: text);
      }
      else{
        _scaffoldKey.currentState.showSnackBar(new SnackBar(content: new Text("他还不是您的好友，请先添加会话")));
      }
    });

  }

  Widget _buildTextComposer(){
    return new IconTheme(
        data: new IconThemeData(color: Theme.of(context).accentColor),
        child: new Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: new Row(
            children: <Widget>[
              new Container(
                margin: new EdgeInsets.symmetric(horizontal: 2.0),
                child: new IconButton(
                    icon: new Icon(Icons.photo_camera),
                    onPressed: () async{
                      //await _ensureLoggedIn();
                      File imageFile = await ImagePicker.pickImage();
                      int random = new Random().nextInt(100000);
                      StorageReference ref = FirebaseStorage.instance.ref().child("image_$random.jpg");
                      StorageUploadTask uploadTask = ref.putFile(imageFile);
                      StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
                      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
                      _sendMessage(imageUrl: downloadUrl);
                    }
                ),
              ),
              new Flexible(
                  child: new TextField(
                    controller: _textController,
                    onChanged: (String text){
                      setState(() {
                        _isComposing = text.length > 0;
                      });
                    },
                    onSubmitted: _handleSubmit,
                    decoration: new InputDecoration.collapsed(hintText: '发送消息'),
                  )
              ),
              new Container(
                  margin: new EdgeInsets.symmetric(horizontal: 2.0),
                  child: new IconButton(
                    icon: new Icon(Icons.send),
                    onPressed: _isComposing? () => _handleSubmit(_textController.text):null,)
              )
            ],
          ),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
        appBar: new AppBar(
          key: _scaffoldKey,
          title: new Text(widget.sheName),
          actions: <Widget>[
            new PopupMenuButton<String>(
                itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
                  new PopupMenuItem<String>(
                      child: new Text("删除会话"),
                      value: "delete",
                  )
                ],
                onSelected: (String value){
                  if(value == "delete"){
                    chatReference
                        .child('${widget.shePhone}/${widget.myPhone}/active')
                        .set("false");
                    chatReference
                        .child('${widget.myPhone}/${widget.shePhone}/active')
                        .set("false");
                    _scaffoldKey.currentState.showSnackBar(new SnackBar(content: new Text("会话已被删除")));
                  }
                },
            ),
          ],
          elevation: 5.0,
        ),
        body: new Column(
          children: <Widget>[
            new Flexible(
//                child: new ListView.builder(
//                  padding: new EdgeInsets.all(8.0),
//                  reverse: true,
//                  itemBuilder: (_,int index) => _messages[index],
//                  itemCount: _messages.length,
//                )
              child: new FirebaseAnimatedList(
                  query: reference.child(_messages),
                  sort: (a,b) => b.key.compareTo(a.key),
                  padding: new EdgeInsets.all(8.0),
                  reverse: true,
                  itemBuilder: (_, DataSnapshot snapshot, Animation<double> animation,int index){
                    //_ensureLoggedIn();
                    return new ChatMessage(
                      snapshot: snapshot,
                      animation: animation,
                    );
                  }
              ),
            ),
            new Divider(height: 1.0,),
            new Container(
              decoration: new BoxDecoration(
                color: Theme.of(context).cardColor,
              ),
              child: _buildTextComposer(),
            )
          ],
        )
    );
  }

//  @override
//  void dispose(){
//    for(ChatMessage message in _messages){
//      message.animationController.dispose();
//    }
//    super.dispose();
//  }
}
