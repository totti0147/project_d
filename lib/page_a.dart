import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_d/dropdown.dart';

class PageA extends ConsumerWidget {
  const PageA({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: <Widget>[
        Stack(
          children: <Widget>[
            Container(margin: EdgeInsets.fromLTRB(32, 16, 0, 0),
              child: Text('How do you say this in Japanese?',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold
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
                        color: Colors.black
                    ),
                  ),
                  child: TextField(
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
              child: Icon(Icons.send,
                  color: Colors.blue),
            )
          ],
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: Container(
                margin: EdgeInsets.fromLTRB(10, 0, 100, 0),
                child: Text('All your requests',
                ),
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
                    child: Text(
                      'It was just failure after failure. I had to try lots of things befoe I found a way that worked for me.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.indigo,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(40, 62, 6, 40),
                    child: Text(
                      'それはもう挫折の連続でした。自分に合った方法を見つけるまで色々試したよ。',
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

class MyList extends ConsumerWidget{
  const MyList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myModel = ref.watch(MyNotifierProvider).myModel;
    return Stack(
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
    );
  }
}