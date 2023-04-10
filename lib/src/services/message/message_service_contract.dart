import 'package:cmtchat/src/models/message.dart';
import 'package:cmtchat/src/models/user.dart';
import 'package:flutter/cupertino.dart';

abstract class IMessageService {
  Future<bool> send(Message message);
  Stream<Message> messages({@required User activeUser});
  dispose();
}