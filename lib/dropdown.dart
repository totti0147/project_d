import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

class CreateDropdown extends StatefulWidget {
  @override
    State<CreateDropdown> createState() => _CreateDropdown();
  }

class _CreateDropdown extends State<CreateDropdown> {
  String? isSelectedItem = 'All';

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 92,
        child: DropdownButton(
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Colors.redAccent
          ),
          alignment: Alignment.centerRight,
          padding: EdgeInsets.fromLTRB(0,2,10,2),
          isDense: true,
          iconSize: 22,
          underline: Container(),
          dropdownColor: Colors.white,
          value: isSelectedItem,
          iconEnabledColor: Colors.blue,
          items: const[
            DropdownMenuItem(
                child: Text('All',),
                value: 'All',
            ),
            DropdownMenuItem(
              child: Text('Backlog'),
              value: 'Backlog',
            ),
            DropdownMenuItem(
              child: Text('Done'),
              value: 'Done',
            ),
            DropdownMenuItem(
              child: Text('Stars'),
              value: 'Stars',
            ),
          ],
          onChanged: (String? value) {
            setState(() {
              isSelectedItem = value;
            });
          },
        ),
      );
    }
  }
