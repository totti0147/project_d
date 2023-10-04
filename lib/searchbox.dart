import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_d/page_a.dart';
import 'package:project_d/appbar.dart';

final searchBarControllerProvider = StateNotifierProvider<SearchBarController, dynamic>((_) => SearchBarController());

class SearchBarController extends StateNotifier<String> {
  SearchBarController(): super('');

  void update(String newQuery) {
    state = newQuery;

  }
}

final filteredListModelProvider = Provider((ref) {
  final searchQuery = ref.watch(searchBarControllerProvider);
  final allModels = ref.watch(allModelsProvider);
  return allModels.where((model) => model.title.contains(searchQuery)).toList();
  });

final allModelsProvider = Provider((_) => []);//検索対象のモデルを[]の中に入れる

class SearchBar extends HookConsumerWidget {

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterdList = ref.watch(filteredListModelProvider);

    return TextField(
      decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
        ),
      ),
      onChanged: (newQuery) {
        ref.read(searchBarControllerProvider)!.update(newQuery);
      },
    );
  }
}
