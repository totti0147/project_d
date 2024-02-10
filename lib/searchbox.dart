import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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








