import 'package:flutter/material.dart';
import 'package:project_d/dropdown.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:project_d/page_d.dart';

class MyModel {
  String myEng;
  String myJpn;

  MyModel({this.myEng = "",this.myJpn = ""});
  }

class MyNotifier extends ChangeNotifier {
  MyModel _myModel = MyModel();
  MyModel get myModel => _myModel;

  void updateEng(String text) {
    _myModel.myEng = text;
    notifyListeners();
  }
  void updateJpn(String text) {
    _myModel.myJpn = text;
    notifyListeners();
  }
}

final MyNotifierProvider = ChangeNotifierProvider((ref) => MyNotifier());

void receiveTextData(String eng, String jpn) {
  final myNotifier = MyNotifier();

  myNotifier.updateEng(eng);
  myNotifier.updateJpn(jpn);
}

class Test extends ConsumerWidget {
  const Test({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Container(
                margin: EdgeInsets.fromLTRB(10, 0, 100, 0),
                child: Text('Vocab list',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            CreateDropdown(),
          ],
        ),
        Flexible(
          child: ListView(
            children: <Widget>[
              MyListB(),
            ],
          ),
        ),
      ],
    );
  }
}

class MyListB extends ConsumerWidget{
  const MyListB({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myModel = ref.watch(MyNotifierProvider).myModel;
    return Column(
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
                  color: Colors.black
                ),
              ),
              child: Align(
                alignment: Alignment(-0.984, -0.96),
                child: Icon(Icons.star,color: Colors.grey),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(41, 6, 10, 100),
              child: Text(myModel.myEng,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.indigo,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(40, 62, 6, 40),
              child: Text(myModel.myJpn,
                style: TextStyle(
                fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ]
    );
  }
}