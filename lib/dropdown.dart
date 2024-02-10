import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:project_d/main.dart';
import 'package:project_d/fetchData.dart';

class CreateDropdown extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedItem = ref.watch(selectedDropdownItemForAProvider);

    return Container(
      width: 92,
      child: DropdownButton<String>(
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Colors.redAccent
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.fromLTRB(0, 2, 10, 2),
        isDense: true,
        iconSize: 24,
        underline: Container(),
        dropdownColor: Colors.white,
        value: selectedItem,
        iconEnabledColor: Colors.blue,
        items: const [
          DropdownMenuItem(
            child: Text('All'),
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
          ref.read(selectedDropdownItemForAProvider.notifier).state = value ?? 'All';
          // combinedItemsProviderを再読み込みする
          ref.refresh(combinedItemsProvider(value ?? 'All'));
        },
      ),
    );
  }
}

