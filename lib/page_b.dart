import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:project_d/dropdown.dart';

class PageB extends ConsumerWidget {
  const PageB({super.key});

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
              ListForB(),
            ],
          ),
        ),
      ],
    );
  }
}

class Model {
  String eng;
  String jpn;

  Model({this.eng = "",this.jpn = ""});
}

class NotifierForB extends ChangeNotifier {
  Model _model = Model();
  Model get model => _model;

  void updateEng(String text) {
    _model.eng = text;
    notifyListeners();
  }
  void updateJpn(String text) {
    _model.jpn = text;
    notifyListeners();
  }
}

final NotifierForBProvider = ChangeNotifierProvider((ref) => NotifierForB());

void receiveTextDate(String eng, String jpn) {
  final notifierForB = NotifierForB();

  notifierForB.updateEng(eng);
  notifierForB.updateJpn(jpn);
}

class ListForB extends ConsumerWidget{
  const ListForB({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myModel = ref.watch(NotifierForBProvider).model;
    return Stack(
      children: <Widget>[
        Container(
          margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
          height: 140,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
                width: 2,
                color: Colors.black
            ),
          ),
          child: Align(
            alignment: Alignment(-0.98, -0.89),
            child: Icon(Icons.star,color: Colors.grey),
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(44, 6, 6, 100),
          child: Text(myModel.eng,
            style: TextStyle(
              fontSize: 16,
              color: Colors.indigo,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(44, 54, 6, 40),
          child: Text(myModel.jpn,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}







