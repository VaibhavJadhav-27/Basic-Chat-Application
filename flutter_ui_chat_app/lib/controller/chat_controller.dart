import 'package:flutter_ui_chat_app/model/message.dart';
import 'package:get/get.dart';

class ChatController extends GetxController {
  var chatmessage = <Message>[].obs;
  var connecteduser = 0.obs;
}
