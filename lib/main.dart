import 'package:riverpod/riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/material/input_decorator.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_d/page_a.dart';
import 'package:project_d/page_b.dart';
import 'package:project_d/page_c.dart';
import 'package:project_d/page_d.dart';
import 'package:project_d/dropdown.dart';
import 'package:project_d/appbar.dart';
import 'package:project_d/createModel.dart';

final selectedDropdownItemProvider = StateProvider<String>((ref) => 'All');
final selectedDropdownItemForAProvider = StateProvider<String>((ref) => 'All');

void main() {
  const scope = ProviderScope(child: MyApp());
  runApp(scope);
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.montserratTextTheme(
          Theme.of(context).textTheme,
        )
      ),
      home: MyStatefulWidget(),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({super.key});

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  int selectedIndex = 0;
  final pages = [
    TextPostScreen(),
    PostList(),
    Test(),
    PageB(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      appBar: CreateAppBar(),
      body: pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Flash Card',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Setting',
          ),
        ],
        currentIndex: selectedIndex,
        backgroundColor: Colors.white,
        fixedColor: Colors.red,
        onTap: (index) => setState(() => selectedIndex = index),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

