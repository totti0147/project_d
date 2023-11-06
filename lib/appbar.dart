import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_d/searchbox.dart';


class CreateAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CreateAppBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
        backgroundColor: Colors.red,
        leading: Icon(Icons.menu),
        title: Container(
          width: 300,
          height: 40,
          child: SearchBox(),
        )
      );
    }
  }