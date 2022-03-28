import 'dart:async';
import 'dart:convert';
import 'package:pusher_client/pusher_client.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'message_model.dart';
import 'message_db.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

String randomString() {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(255));
  return base64UrlEncode(values);
}

class Chat extends StatefulWidget {
  const Chat({Key? key, required this.name, required this.phone}) : super(key: key);
  final String name;
  final String phone;
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  late PusherClient pusher;
  late Channel channel;
  ScrollController _scrollController = new ScrollController();
  final myController = TextEditingController();
  List<TextMsg> messages = [];
  String userId = '0712345786'; // TODO: get this dynamically
  String username = "me";

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  late TextMsg incomingMsg;

  @override
  void initState() {
    super.initState();
    pusher = PusherClient(
      "66b80d0857f8dd93e43d", // app key
      PusherOptions(
          encrypted: false,
          cluster: "ap2"
      ),
      enableLogging: true,
    );
    pusher.connect();

    //subscribe to the channel
    channel = pusher.subscribe("SPU-CHAT");

    // listen to all messages coming to you; event name is your userId
    channel.bind(userId, (msg) async {
      // convert incoming messages to json format
      var convert = await json.decode(msg!.data!);
      print("The message is ${convert['message']}");

      // create a TextMsg from the incoming message
      incomingMsg = TextMsg(id: randomString(), senderId: convert['message']['sender_id'], message: convert['message']['message'], receiverId: convert['message']['receiver_id']);
      print("msg" + incomingMsg.toString());

      // add the incoming message to the database
      MessageDatabase.instance.create(incomingMsg).then((value) =>
      {
        setState(() {
          refreshMessages();
        })
      });
    });

    refreshMessages().whenComplete(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  Future refreshMessages() async {
    //messages sent to a particular person
    this.messages = await MessageDatabase.instance.readMessages(widget.phone);
  }

  // send a post request to the laravel application. The laravel app will send the message to Pusher
  // TODO: replace url with spu server url
  postRequest() async{
    http.Response response = await http
        .post(Uri.parse("http://192.168.0.26/chat/public/api/push_message"), headers: {
      "Accept": "application/json"
    }, body: {
      "sender_id" : userId,
      "sender_name" : username,
      "message": myController.text,
      "receiver_id": widget.phone
    });
    var converted = json.decode(response.body);
    myController.clear();
    print("status code: " + response.statusCode.toString());
  }

  //positions message on either the left or right depending on the sender
  Widget _buildMessage(String message, String sender) {
    if (sender == widget.phone) {
      return leftBox(message);
    } else {
      return rightBox(message);
    }
  }

  Widget rightBox(msg){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(),
        Padding(
          padding: EdgeInsets.all(10),
          child: Container(
            constraints: BoxConstraints(minWidth: 100, maxWidth: 220),
            decoration: BoxDecoration(
                color: Colors.grey[300],
                border: Border.all(
                  color: Colors.grey[300]!,
                ),
                borderRadius: BorderRadius.circular(15)
            ),
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Text(
                msg,
                style: TextStyle(
                    color: Colors.black
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget leftBox(msg){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.all(10),
          child: Container(
            constraints: BoxConstraints(minWidth: 100, maxWidth: 220),
            decoration: BoxDecoration(
                color: Colors.brown[300],
                border: Border.all(
                  color:Colors.brown[300]!,
                ),
                borderRadius: BorderRadius.circular(15)
            ),
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Text(
                msg,
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
        SizedBox(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.brown,
          title: Text(widget.name),
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _buildMessage(messages[index].message, messages[index].senderId);
                  },
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey[300]!,
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(25.0),
                ),
                padding: EdgeInsets.all(5.0),
                margin: EdgeInsets.all(15),
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      width: 10.0,
                    ),
                    Expanded(
                      child: TextField(
                        controller: myController,
                        decoration: InputDecoration(
                          hintText: 'Type a message',
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    IconButton(
                        icon: Icon(Icons.send),
                        onPressed: ()  {
                          if(myController.text.isNotEmpty){
                            MessageDatabase.instance.create(TextMsg(id: randomString(), senderId: userId, message: myController.text, receiverId: widget.phone)).then((value) => {
                              setState(() {
                                refreshMessages(); //scroll automatically
                              })
                            });
                            postRequest();
                          }
                        }
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
