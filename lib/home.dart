import 'package:flutter/material.dart';
import 'chat.dart';
import 'package:pusher_client/pusher_client.dart';
import 'dart:convert';

String _title = "Students";

// TODO: populate list with students that have started chats
var students = {};

class CounsellorsHome extends StatefulWidget {
  const CounsellorsHome({Key? key}) : super(key: key);

  @override
  _CounsellorsHomeState createState() => _CounsellorsHomeState();
}

class _CounsellorsHomeState extends State<CounsellorsHome> {
  late PusherClient pusher;
  late Channel channel;
  String userId = '0712345786'; // TODO: get this dynamically

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

      //add student to list if he/she has never started a chat before
      var newStudent = students.putIfAbsent(convert['message']['sender_id'], () => convert['message']['sender_name']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title), backgroundColor: Colors.brown,),
      body: students.isNotEmpty
          ? ListView.builder(
        itemCount: students.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            leading: Image.asset('assets/images/Virtual_Mentorship_Icon.png'), //TODO: use a dynamic image
            title: Text(students.values.elementAt(index)),
            subtitle: Text("Mental health and wellbeing"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Chat(name: students.values.elementAt(index), phone: students.keys.elementAt(index))
                ),
              );
            },
          );
        },
      )
          : const Center(child: Text('No items')),
    );
  }
}