import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:project_d/appbar.dart';
import 'package:project_d/searchbox.dart';
import 'package:project_d/main.dart';

final postsProvider = FutureProvider<List<Post>>((ref) async {
  final response = await http.get(Uri.parse('http://192.168.150.5:3000/allItems'));
  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonData = json.decode(response.body);

    // 各カテゴリからデータを取得し、それらを一つのリストに結合
    final List<dynamic> allPostsData = jsonData['allPosts'] ?? [];
    final List<dynamic> myPostsData = jsonData['myPosts'] ?? [];
    final List<dynamic> backlogData = jsonData['myPostsForBacklog'] ?? [];
    final List<dynamic> doneData = jsonData['myPostsForDone'] ?? [];

    // すべてのデータをPostオブジェクトのリストに変換
    final List<Post> allPosts = allPostsData.map((item) => Post.fromJson(item)).toList();
    final List<Post> myPosts = myPostsData.map((item) => Post.fromJson(item)).toList();
    final List<Post> backlogPosts = backlogData.map((item) => Post.fromJson(item)).toList();
    final List<Post> donePosts = doneData.map((item) => Post.fromJson(item)).toList();

    // すべてのリストを結合
    final List<Post> combinedPosts = allPosts + myPosts + backlogPosts + donePosts;

    return combinedPosts;
  } else {
    throw Exception('Failed to load posts: ${response.statusCode}');
  }
});

final filteredItemsProvider = FutureProvider.family<List<Post>, String>((ref, filter) async {
  final response = await http.get(Uri.parse('http://192.168.150.5:3000/allItems'));

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonData = json.decode(response.body);
    final searchQuery = ref.watch(searchProvider).toLowerCase();

    final List<dynamic> allPostsData = jsonData['allPosts'] ?? [];
    final List<Post> allPosts = allPostsData.map((item) => Post.fromJson(item)).toList();

    List<Post> filteredPosts;
    if (filter == 'All') {
      filteredPosts = allPosts;
    } else if (filter == 'Stars') {
      final favorites = ref.watch(favoritesProvider);
      filteredPosts = allPosts.where((post) => favorites.contains(post.number)).toList();
    } else {
      filteredPosts = allPosts;
    }

    if (searchQuery.isNotEmpty) {
      filteredPosts = filteredPosts.where((post) =>
      post.eng.toLowerCase().contains(searchQuery) || post.jpn.toLowerCase().contains(searchQuery)).toList();
    }

    return filteredPosts;
  } else {
    throw Exception('Failed to load posts');
  }
});

class Post {
  final int number;
  final String jpn;
  final String eng;

  Post({required this.number, required this.jpn, required this.eng});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      number: json['number'] as int,
      jpn: json['jpn'] as String? ?? '', // nullの場合は空文字列を使用
      eng: json['eng'] as String? ?? '', // nullの場合は空文字列を使用
    );
  }
}

final favoritesProvider = StateProvider<List<int>>((ref) => []);

class CreateDropdownForB extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedItem = ref.watch(selectedDropdownItemProvider);

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
            child: Text('Stars'),
            value: 'Stars',
          ),
        ],
        onChanged: (String? value) {
          ref.read(selectedDropdownItemProvider.notifier).state = value ?? 'All';
        },
      ),
    );
  }
}

class PostList extends ConsumerWidget {
  const PostList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(selectedDropdownItemProvider);
    final filteredItemsAsyncValue = ref.watch(filteredItemsProvider(filter));
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      backgroundColor: Colors.teal[50],
      appBar: CreateAppBar(),
      body: Column(
        children: [
          CreateDropdownForB(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.refresh(postsProvider);
              },
              child: filteredItemsAsyncValue.when(
                data: (filteredPosts) {
                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: filteredPosts.length,
                    itemBuilder: (context, index) {
                      final post = filteredPosts[index];
                      final isFavorited = favorites.contains(post.number);
                      return Container(
                        margin: EdgeInsets.fromLTRB(8, 0, 8, 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            width: 1,
                            color: Colors.black
                          ),
                        ),
                        child: Stack(
                          children: [
                            GestureDetector(
                              onTap: () {
                                ref.read(favoritesProvider.notifier).update((state) {
                                  return isFavorited
                                  ? state.where((n) => n != post.number).toList()
                                  : [...state, post.number];
                                });
                              },
                              child: Container(
                                margin: EdgeInsets.fromLTRB(2, 1.6, 0, 0),
                                width: 26,
                                child: Icon(isFavorited ? Icons.star : Icons.star,
                                color: isFavorited ? Colors.yellow[700] : Colors.grey[400],
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.fromLTRB(30,5,6,0),
                                  child: Text(post.eng,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.indigo,
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.fromLTRB(30,0,6,5),
                                  child: Text(post.jpn,
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ]
                            ),
                          ]
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Center(child: Text(error.toString())),
              ),
            ),
          ),
        ],
      ),
    );
  }
}





