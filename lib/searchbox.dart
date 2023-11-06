import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:project_d/page_a.dart';
import 'package:project_d/appbar.dart';
import 'package:project_d/page_d.dart';

final filteredItemsProvider = Provider.autoDispose.family<List<Post>, String>((ref, query) {
  final postsData = ref.watch(postsProvider);

  if (postsData is AsyncData<List<Post>>) {
    final posts = postsData.value;

    if (query.isEmpty) {
      return posts;
    } else {
      return posts.where((item) => item.title.contains(query)).toList();
    }
  } else {
    return <Post>[]; // ローディング中やエラー時は空のリストを返す
  }
});

class SearchBox extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextField(
      onChanged: (query) {
        // フィルタリング用のProviderを更新
        ref.read(filteredItemsProvider(query));
      },
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(),
        hintText: 'Search items...',
      ),
    );
  }
}

class ItemList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredItems = ref.watch(filteredItemsProvider(''));

    return ListView.builder(
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        return ListTile(
          title: Text(item.title),
          subtitle: Text(item.author),
        );
      },
    );
  }
}






