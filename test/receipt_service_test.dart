import 'package:cmtchat/src/models/receipt.dart';
import 'package:cmtchat/src/models/user.dart';
import 'package:cmtchat/src/services/receipt/receipt_service_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethinkdb_dart/rethinkdb_dart.dart';
import 'helpers.dart';

void main() {
  Rethinkdb r = Rethinkdb();
  Connection connection;
  ReceiptService sut;

  setUp(() async {
    connection = await r.connect();
    await createDb(r, connection);
    sut = ReceiptService(r, connection);
  });

  tearDown(() async {
    sut.dispose();
    await cleanDb(r, connection);
  });

  final user = User.fromJson({
    'id': '1234',
    'active': true,
    'last_seen': DateTime.now(),
  });
  
  test('Sent receipt successfully', () async {
    Receipt receipt = Receipt(
        recipient: '1234',
        messageId: '1234',
        status: ReceiptStatus.sent,
        timestamp: DateTime.now());

    final res = await sut.send(receipt);
    expect(res, true);
  });

  test('Receving receipts successfully', () async {
    sut.receipts(user).listen((receipt) {
      expect(receipt.recipient, '1234');
      expect(receipt.status, ReceiptStatus.sent);
    });

    Receipt receipt = Receipt(
        recipient: '1234',
        messageId: '1234',
        status: ReceiptStatus.sent,
        timestamp: DateTime.now());
    sut.send(receipt);
  });
}