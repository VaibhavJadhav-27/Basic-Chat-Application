// ignore_for_file: prefer_const_constructors, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, unused_local_variable, library_prefixes, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_ui_chat_app/controller/chat_controller.dart';
import 'package:flutter_ui_chat_app/model/message.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
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
  ChatController chatController = ChatController();

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
      backgroundColor: Colors.grey[600],
      body: Container(
        child: Column(
          children: [
            Expanded(
                child: Obx(
              () => Container(
                padding: EdgeInsets.all(10),
                child: Text(
                  "Connected User  ${chatController.connecteduser} ",
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            )),
            Expanded(
                flex: 9,
                child: Obx(
                  () => ListView.builder(
                      itemCount: chatController.chatmessage.length,
                      itemBuilder: (context, index) {
                        var currentitem = chatController.chatmessage[index];
                        return MessageItem(
                          sentbyme: currentitem.sentbyme == socket.id,
                          message: currentitem.message,
                        );
                      }),
                )),
            Expanded(
                child: Container(
              padding: EdgeInsets.all(10),
              color: Colors.grey[800],
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
    chatController.chatmessage.add(Message.fromJson(messagejson));
  }

  void setupsocketlistner() {
    socket.on('message-receive', (data) {
      print(data);
      chatController.chatmessage.add(Message.fromJson(data));
    });
    socket.on('connected-user', (data) {
      print(data);
      chatController.connecteduser.value = data;
    });
  }
}

class MessageItem extends StatelessWidget {
  const MessageItem({Key? key, required this.sentbyme, required this.message})
      : super(key: key);

  final bool sentbyme;
  final String message;

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
              message,
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
