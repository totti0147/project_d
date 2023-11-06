import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:project_d/dropdown.dart';

final textSendingProvider = FutureProvider<void>((ref) async {
  final text = ref.read(textEditingControllerProvider).text;
  final serverUrl = 'http://192.168.1.124:3000/posts';

  if (text.isNotEmpty) {
    final response = await http.post(
      Uri.parse(serverUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'text': text}),
    );

    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception('Failed to send text. Status code: ${response.statusCode}');
    }
  }
});

final textEditingControllerProvider = Provider<TextEditingController>((ref) {
  return TextEditingController();
});

class TextPostScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textSendingAsyncValue = ref.watch(textSendingProvider);

    return Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Container(
                margin: EdgeInsets.fromLTRB(32, 16, 0, 0),
                child: Text('How do you say this in Japanese?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ExpansionTile(
                title: Text(''),
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(8, 0, 8, 10),
                    height: 140,
                    width: 800,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        width: 2,
                        color: Colors.black,
                      ),
                    ),
                    child: TextField(
                      controller: ref.watch(textEditingControllerProvider),
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(10, 36, 0, 36),
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 320,
                right: 20,
                top: 146,
                bottom: 10,
                child: IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: () async {
                    final textToSend = ref.read(textEditingControllerProvider).text;
                    if (textToSend.isNotEmpty) {
                      await ref.read(textSendingProvider);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Text sent successfully')),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  margin: EdgeInsets.fromLTRB(10, 0, 100, 0),
                  child: Text('All your requests'),
                ),
              ),
              CreateDropdown(),
            ],
          ),
          Flexible(
            child: ListView(
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.fromLTRB(8, 0, 8, 0),
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          width: 2,
                          color: Colors.black,
                        ),
                      ),
                      child: Align(
                        alignment: Alignment(-0.984, -0.96),
                        child: Icon(Icons.star, color: Colors.grey),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(41, 6, 10, 100),
                      child: Text('It was just failure after failure. I had to try lots of things before I found a way that worked for me.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.indigo,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(40, 62, 6, 40),
                      child: Text('それはもう挫折の連続でした。自分に合った方法を見つけるまで色々試したよ。',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    }
  }