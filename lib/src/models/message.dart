import 'package:flutter/cupertino.dart';

class Message {
  String get id => _id;
  final String from;
  final String to;
  final DateTime timestamp;
  final String contents;
  String _id;

  Message({
    @required this.from,
    @required this.to,
    @required this.timestamp,
    @required this.contents,
  });

  toJson() => {
    'from': from,
    'to': to,
    'timestamp': timestamp,
    'contents': contents
  };

  factory Message.fromJson(Map<String, dynamic> json) {
    var message = Message(
        from: json['from'],
        to: json['to'],
        timestamp: json['timestamp'],
        contents: json['contents']
    );

    message._id = json['id'];
    return message;
  }

}