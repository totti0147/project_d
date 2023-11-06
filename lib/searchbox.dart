import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:project_d/page_a.dart';
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

final filteredItemsProvider = FutureProvider.family<List<Post>, String>((ref, search) async {
  final response = await http.get(Uri.parse('http://192.168.1.124:3000/posts'),
    headers: {'Accept-Charset': 'utf-8'},
  );
  print('Status Code: ${response.statusCode}');
  print('Body: ${response.body}');

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    final List<Post> posts = data.map((item) => Post.fromJson(item)).toList();

    if (search.isEmpty) {
      return posts;
    }

    return posts.where((post) => post.title.toLowerCase().contains(search.toLowerCase())).toList();
  } else {
    throw Exception('Failed to load posts');
  }
});

class SearchBox extends ConsumerWidget {

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchNotifier = ref.watch(searchProvider.notifier);
    return TextField(
      onChanged: (value) => searchNotifier.updateSearch(value),
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(),
        hintText: 'Search items...',
      ),
    );
  }
}








