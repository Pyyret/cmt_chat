import 'package:cmtchat/src/models/typing_event.dart';
import 'package:cmtchat/src/models/user.dart';
import 'package:flutter/cupertino.dart';

abstract class ITypingNotification {
  Future<bool> send({ @required TypingEvent event });
  Stream<TypingEvent> subscribe(User user, List<String> userIds);
  void dispose();
}