import 'package:cmtchat/src/models/typing_event.dart';
import 'package:cmtchat/src/models/user.dart';
import 'package:cmtchat/src/services/typing/typing_notification_service_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethinkdb_dart/rethinkdb_dart.dart';

import 'helpers.dart';

void main() {
  Rethinkdb r = Rethinkdb();
  Connection connection;
  TypingNotification sut;

  setUp(() async {
    connection = await r.connect();
    await createDb(r, connection);
    sut = TypingNotification(r, connection);
  });
  
  tearDown(() async {
    sut.dispose();
    await cleanDb(r, connection);
  });

  final user1 = User.fromJson({
    'id': '1111',
    'active': true,
    'last_seen': DateTime.now(),
  });

  final user2 = User.fromJson({
    'id': '222',
    'active': true,
    'last_seen': DateTime.now(),
  });
  
  test('Sent typing notification successfully', () async {
    TypingEvent typingEvent = TypingEvent(
        from: user1.id,
        to: user2.id,
        event: Typing.start);

    final res = await sut.send(event: typingEvent, to: user2);
    expect(res, true);
  });

  test('Subscribe and receive typing events successfully', () async {
    sut.subscribe(user2, [user1.id]).listen(expectAsync1((event) {
      expect(event.from, user1.id);
    }, count: 2));

    TypingEvent typing = TypingEvent(
        from: user1.id,
        to: user2.id,
        event: Typing.start);

    TypingEvent stopTyping = TypingEvent(
        from: user1.id,
        to: user2.id,
        event: Typing.stop);

    await sut.send(event: typing, to: user2);
    await sut.send(event: stopTyping, to: user2);
  });
}