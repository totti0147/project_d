import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:project_d/page_a.dart';
import 'package:project_d/page_b.dart';
import 'package:project_d/appbar.dart';
import 'package:project_d/page_d.dart';

class SearchNotifier extends StateNotifier<String> {
  SearchNotifier() : super('');

  void updateSearch(String newSearch) {
    state = newSearch;
  }
}

final searchProvider = StateNotifierProvider<SearchNotifier, String>((ref) {
  return SearchNotifier();
});

class SearchBox extends ConsumerWidget {

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchNotifier = ref.watch(searchProvider.notifier);
    return TextField(
      onChanged: (value) => searchNotifier.updateSearch(value),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(10,5,0,5),
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(),
      ),
    );
  }
}








