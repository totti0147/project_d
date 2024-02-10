import 'package:riverpod/riverpod.dart';
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_d/page_a.dart';
import 'package:project_d/page_b.dart';
import 'package:project_d/page_c.dart';
import 'package:project_d/page_d.dart';
import 'package:project_d/createModel.dart';

final selectedDropdownItemProvider = StateProvider<String>((ref) => 'All');
final selectedDropdownItemForAProvider = StateProvider<String>((ref) => 'All');

void main() {
  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => ProviderScope(child: MyApp()),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: ThemeData(
        textTheme: GoogleFonts.mPlusRounded1cTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: MyStatefulWidget(),
    );
  }
}

final selectedIndexProvider = StateProvider<int>((ref) => 0);

class MyStatefulWidget extends ConsumerWidget {
  const MyStatefulWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedIndexProvider.state).state;
    final pages = [
      TextPostScreen(),
      PostList(),
      FlashCardPage(),
      FlashCardPageD(),
    ];

    return Scaffold(
      backgroundColor: Colors.teal[50],
      body: pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
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
        onTap: (index) => ref.read(selectedIndexProvider.state).state = index,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}