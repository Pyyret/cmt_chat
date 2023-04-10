import 'dart:async';
import 'package:cmtchat/src/models/message.dart';
import 'package:cmtchat/src/models/user.dart';
import 'package:cmtchat/src/services/Encryption/encryption_contract.dart';
import 'package:cmtchat/src/services/message/message_service_contract.dart';
import 'package:rethinkdb_dart/rethinkdb_dart.dart';

class MessageService implements IMessageService {
  final Connection _connection;
  final Rethinkdb r;
  final IEncryption _encryption;

  final _controller = StreamController<Message>.broadcast();
  StreamSubscription _changeFeed;

  MessageService(this.r, this._connection, this._encryption);

  @override
  dispose() {
    _changeFeed?.cancel();
    _controller?.close();
  }

  @override
  Stream<Message> messages({User activeUser}) {
    _startRecievingMessages(activeUser);
    return _controller.stream;
  }

  @override
  Future<bool> send(Message message) async {
    var data = message.toJson();
    data['contents'] = _encryption.encrypt(message.contents);
    Map record = await r
        .table('messages')
        .insert(data)
        .run(_connection);

    return record['inserted'] == 1;
  }

  _startRecievingMessages(User user) {
    _changeFeed = r
        .table('messages')
        .filter({'to' : user.id})
        .changes({'include_initial': true})
        .run(_connection)
        .asStream()
        .cast<Feed>()
        .listen((event) {
          event.forEach((feedData) {
            if(feedData['new_val'] == null) return;

            final message = _messageFromFeed(feedData);
            _controller.sink.add(message);
            _removeDeliveredMessage(message);
          }).onError((err, stackTrace) => print(err));
    });
  }

  Message _messageFromFeed(feedData) {
    var data = feedData['new_val'];
    data['contents'] = _encryption.decrypt(data['contents']);

    return Message.fromJson(data);
  }

  _removeDeliveredMessage(Message message) {
    r
        .table('messages')
        .get(message.id)
        .delete({'return_changes': false})
        .run(_connection);
  }
}