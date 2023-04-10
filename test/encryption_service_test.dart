import 'package:cmtchat/src/services/Encryption/encryption_contract.dart';
import 'package:cmtchat/src/services/Encryption/encryption_service_impl.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_test/flutter_test.dart';

main() {
  IEncryption sut;

  setUp(() {
    final encrypter = Encrypter(AES(Key.fromLength(32)));
    sut = EncryptionService(encrypter);
  });

  test('tests encryption of plain text', () {
    final text = 'This is a message';
    final base64 = RegExp(r'^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{4})$');
    final encrypted = sut.encrypt(text);

    expect(base64.hasMatch(encrypted), true);
  });

  test('it decrypts the encrypted text', () {
    final text = 'Hello (hello..hello), is there anybody out there?';
    final encrypted = sut.encrypt(text);
    final decrypted = sut.decrypt(encrypted);

    expect(decrypted, text);
  });
}