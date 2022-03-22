import 'package:flutter/material.dart';
import 'chat.dart';

String _title = "Counsellors";

List<Map<String, String>> counsellors = [
  {
    'name': 'Anne',
    'phone': '0706780121'
  },
  {
    'name': 'Mary',
    'phone': '0712345678'
  },
  {
    'name': "Tom",
    'phone': '0723546789'
  }
];

class CounsellorsHome extends StatefulWidget {
  const CounsellorsHome({Key? key}) : super(key: key);

  @override
  _CounsellorsHomeState createState() => _CounsellorsHomeState();
}

class _CounsellorsHomeState extends State<CounsellorsHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title), backgroundColor: Colors.brown,),
      body: counsellors.isNotEmpty
          ? ListView.builder(
        itemCount: counsellors.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            leading: Image.asset('assets/images/Virtual_Mentorship_Icon.png'),
            title: Text(counsellors[index]["name"]!),
            subtitle: Text("Mental health and wellbeing"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Chat(name: counsellors[index]["name"]!, phone: counsellors[index]["phone"]!)
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