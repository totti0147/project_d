import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:project_d/searchbox.dart';
import 'package:project_d/main.dart';

final postsProvider = FutureProvider<List<Post>>((ref) async {
  final response = await http.get(Uri.parse('http://192.168.1.124:3000/allItems'));
  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    final List<dynamic> postsData = data['allPosts'];
    final List<Post> allPosts = postsData.map((item) => Post.fromJson(item)).toList();
    return allPosts;
  } else {
    throw Exception('Failed to load posts: ${response.statusCode}');
  }
});

final filteredItemsProvider = FutureProvider.family<List<Post>, String>((ref, filter) async {
  final response = await http.get(Uri.parse('http://192.168.1.124:3000/allItems'));
  final selectedItem = ref.watch(selectedDropdownItemProvider);
  final search = ref.watch(searchProvider);

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    final List<dynamic> postsData = data['allPosts'];
    final List<Post> allPosts = postsData.map((item) => Post.fromJson(item)).toList();

    List<Post> filteredPosts = allPosts;

    // Dropdownフィルターの適用
    if (selectedItem == 'Stars') {
      final favorites = ref.watch(favoritesProvider);
      filteredPosts = filteredPosts.where((post) => favorites.contains(post.number)).toList();
    }

    // 検索フィルターの適用
    if (search.isNotEmpty) {
      filteredPosts = filteredPosts.where((post) => post.title.toLowerCase().contains(search.toLowerCase())).toList();
    }

    return filteredPosts;
  } else {
    throw Exception('Failed to load posts');
  }
});

class Post {
  final int number;
  final String title;
  final String jpn;

  Post({required this.number, required this.title, required this.jpn});

  factory Post.fromJson(Map<String, dynamic> json) {
    final number = json['number'] as int;
    final title = json['title'] as String;
    final jpn = json['jpn'] as String;

    return Post(
      number: number,
      title: title,
      jpn: jpn,
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
        style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Colors.redAccent
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.fromLTRB(0, 2, 10, 2),
        isDense: true,
        iconSize: 22,
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

    return Column(
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
                          width: 2,
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
                                color: isFavorited ? Colors.yellow[800] : Colors.grey[400],
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.fromLTRB(30,5,6,0),
                                child: Text(post.title,
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
    );
  }
}





