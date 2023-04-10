import 'package:cmtchat/src/models/message.dart';
import 'package:cmtchat/src/models/user.dart';
import 'package:cmtchat/src/services/Encryption/encryption_service_impl.dart';
import 'package:cmtchat/src/services/message/message_service_impl.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethinkdb_dart/rethinkdb_dart.dart';
import 'helpers.dart';

void main() {
  Rethinkdb r = Rethinkdb();
  Connection connection;
  MessageService sut;

  setUp(() async {
    connection = await r.connect(host: '127.0.0.1', port: 28015);
    final encryption =  EncryptionService(Encrypter(AES(Key.fromLength(32))));
    await createDb(r, connection);
    sut = MessageService(r, connection, encryption);
  });

  tearDown(() async {
    sut.dispose();
    await cleanDb(r, connection);
  });

  final user1 = User.fromJson({
    'id': '1111',
    'active': true,
    'last_seen': DateTime.now()
  });

  final user2 = User.fromJson({
  'id': '2222',
  'active': true,
  'last_seen': DateTime.now()
  });

  test('sent message successfully', () async {
    Message message = Message(
        from: user1.id,
        to: user2.id,
        timestamp: DateTime.now(),
        contents: 'TESTINGTESTING!');

    final res = await sut.send(message);
    expect(res, true);
  });

  test('Successfully subscribe and receive messages being sent', () async {
    final content = 'TESTINGTESTING!';

    sut.messages(activeUser: user1).listen(expectAsync1((message) {
      expect(message.to, user1.id);
      expect(message.id, isNotEmpty);
      expect(message.contents, content);
    }, count: 2));

    Message message = Message(
        from: user2.id,
        to: user1.id,
        timestamp: DateTime.now(),
        contents: content);

    Message message2 = Message(
        from: user2.id,
        to: user1.id,
        timestamp: DateTime.now(),
        contents: content);

    await sut.send(message);
    await sut.send(message2);
  });

  test('Successfully subscribe and receive new messages when logging on', () async {

    Message message = Message(
        from: user2.id,
        to: user1.id,
        timestamp: DateTime.now(),
        contents: 'TESTINGTESTING!');

    Message message2 = Message(
        from: user2.id,
        to: user1.id,
        timestamp: DateTime.now(),
        contents: 'TESTING AGAIN!');

    /// Sending the messages first
    await sut.send(message);
    await sut.send(message2)

    /// And then subscribing to the stream
        .whenComplete(() =>
        sut.messages(activeUser: user1).listen(expectAsync1((message) {
          expect(message.to, user1.id);
          expect(message.id, isNotEmpty);
    }, count: 2)));

  });
}