import 'package:channel_unread_count_issue/main.dart';
import 'package:flutter/material.dart';

class UnreadCount extends StatefulWidget {
  const UnreadCount({Key? key}) : super(key: key);

  @override
  _UnreadCountState createState() => _UnreadCountState();
}

class _UnreadCountState extends State<UnreadCount> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Channel unread count"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Total channel unread count",style: TextStyle(fontSize: 18),),
            SizedBox(height: 50,),
            Text("0"),
            const SizedBox(height: 100,),
            MaterialButton(
              onPressed: (){
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>const MyHomePage(title: 'Total channel unread count demo')), (route) => false);
              },
              child: const Text("Logout"),
              color: Colors.grey,
            ),

          ],
        ),
      ),
    );
  }
}
