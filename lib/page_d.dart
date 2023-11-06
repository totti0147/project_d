import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_d/searchbox.dart';


final postsProvider = FutureProvider<List<Post>>((ref) async {
  final response = await http.get(Uri.parse('http://192.168.1.124:3000/posts'));
  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    final List<Post> posts = data.map((item) => Post.fromJson(item)).toList();
    return posts;
  } else {
    throw Exception('Failed to load posts');
  }
});



class Post {
  final int number;
  final String title;
  final String author;

  Post({required this.number, required this.title, required this.author});

  factory Post.fromJson(Map<String, dynamic> json) {
    final number = json['number'] as int;
    final title = json['title'] as String;
    final author = json['author'] as String;

    return Post(
      number: number,
      title: title,
      author: author,
    );
  }
}

class PostList extends ConsumerWidget {
  const PostList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final search = ref.watch(searchProvider);
    final filteredItemsAsyncValue = ref.watch(filteredItemsProvider(search));

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.refresh(filteredItemsProvider(search));
            },
            child: filteredItemsAsyncValue.when(
              data: (posts) {
                return ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return Container(
                      margin: EdgeInsets.fromLTRB(8, 10, 8, 0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                            width: 2,
                            color: Colors.black
                        ),
                      ),
                      child: Stack(
                          children: [
                            Container(
                              margin: EdgeInsets.fromLTRB(2, 1.6, 0, 0),
                              width: 26,
                              child: Icon(Icons.star, color: Colors.grey),
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(14, 0, 0, 0),
                              child: ListTile(
                                title: Text(post.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.indigo,
                                  ),
                                ),
                                subtitle: Text(post.author,
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
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