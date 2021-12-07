// ignore_for_file: prefer_const_constructors, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, unused_local_variable, library_prefixes, avoid_print

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Color green = Colors.greenAccent;
  Color black = Color(0xFF191919);
  TextEditingController messageinputcontro = TextEditingController();
  late IO.Socket socket;

  @override
  void initState() {
    socket = IO.io(
        'http://localhost:4000',
        IO.OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .disableAutoConnect() // disable auto-connection
            .build());
    socket.connect();
    setupsocketlistner();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        child: Column(
          children: [
            Expanded(
                flex: 9,
                child: Container(
                  child: ListView.builder(
                      itemCount: 10,
                      itemBuilder: (context, index) {
                        return MessageItem(
                          sentbyme: false,
                        );
                      }),
                )),
            Expanded(
                child: Container(
              padding: EdgeInsets.all(10),
              color: Colors.blue,
              child: TextField(
                cursorColor: green,
                style: TextStyle(color: Colors.white),
                controller: messageinputcontro,
                decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(10)),
                    suffixIcon: Container(
                      child: IconButton(
                          onPressed: () {
                            sendMessage(messageinputcontro.text);
                            messageinputcontro.text = "";
                          },
                          icon: Icon(
                            Icons.send,
                            color: Colors.white,
                          )),
                    )),
              ),
            ))
          ],
        ),
      ),
    );
  }

  void sendMessage(String text) {
    var messagejson = {"message": text, "sentbyme": socket.id};
    socket.emit('message', messagejson);
  }

  void setupsocketlistner() {
    socket.on('message-receive', (data) {
      print(data);
    });
  }
}

class MessageItem extends StatelessWidget {
  const MessageItem({Key? key, required this.sentbyme}) : super(key: key);

  final bool sentbyme;

  @override
  Widget build(BuildContext context) {
    Color green = Colors.greenAccent;
    Color black = Color(0xFF191919);
    Color white = Colors.white;

    return Align(
      alignment: sentbyme ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        margin: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: sentbyme ? green : white,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              "Hello",
              style: TextStyle(color: sentbyme ? white : black, fontSize: 18),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              " 12:45 pm",
              style: TextStyle(
                  color: (sentbyme ? white : black).withOpacity(0.7),
                  fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
