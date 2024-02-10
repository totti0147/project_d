import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:project_d/appbar.dart';
import 'dart:convert';
import 'package:project_d/dropdown.dart';
import 'package:project_d/main.dart';
import 'package:project_d/fetchData.dart';

final textSendingProvider = FutureProvider<void>((ref) async {
  final text = ref.read(textEditingControllerProvider).text;
  final serverUrl = 'http://192.168.150.5:3000/addToBacklog';
  final requestBody = jsonEncode({'eng': text});

  if (text.isNotEmpty) {
    final response = await http.post(
      Uri.parse(serverUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'eng': text}),
    );

    if (response.statusCode == 201) {
      return;
    } else {
      throw Exception('Failed to send text. Status code: ${response.statusCode}');
    }
  }
});

final textEditingControllerProvider = Provider<TextEditingController>((ref) {
  return TextEditingController();
});

final postsForAProvider = FutureProvider<List<PostForA>>((ref) async {
  final response = await http.get(Uri.parse('http://192.168.150.5:3000/allItems'));
  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);

    String generateUniqueId(Map<String, dynamic> item) {
      return '${item['number']}-${item['eng'].hashCode}';
    }

    final List<PostForA> backlogPosts = (data['myPostsForBacklog'] ?? []).map((item) {
      return PostForA.fromJson(item, id: generateUniqueId(item) + '-Backlog');
    }).cast<PostForA>().toList();

    final List<PostForA> donePosts = (data['myPostsForDone'] ?? []).map((item) {
      return PostForA.fromJson(item, id: generateUniqueId(item) + '-Done');
    }).cast<PostForA>().toList();

    return [...backlogPosts, ...donePosts];
  } else {
    throw Exception('Failed to load posts: ${response.statusCode}');
  }
});

final filteredItemsForAProvider = FutureProvider.family<List<PostForA>, String>((ref, filterForA) async {
  final allPosts = await ref.watch(postsForAProvider.future);
  List<PostForA> filteredPostsForA = allPosts;

  if (filterForA == 'Stars') {
    final favoritesForA = ref.watch(favoritesForAProvider);
    filteredPostsForA = filteredPostsForA.where((post) => favoritesForA.contains(post.id)).toList();
  } else if (filterForA == 'Backlog') {
    filteredPostsForA = filteredPostsForA.where((post) => post.id.endsWith('-Backlog')).toList();
  } else if (filterForA == 'Done') {
    filteredPostsForA = filteredPostsForA.where((post) => post.id.endsWith('-Done')).toList();
  }

  final searchForA = ref.watch(searchForAProvider).toLowerCase();
  if (searchForA.isNotEmpty) {
    filteredPostsForA = filteredPostsForA.where((post) {
      final searchInEng = post.eng.toLowerCase().contains(searchForA);
      final searchInJpn = (post.jpn ?? '').toLowerCase().contains(searchForA);
      return searchInEng || searchInJpn;
    }).toList();
  }

  return filteredPostsForA;
});

class SearchForANotifier extends StateNotifier<String> {
  SearchForANotifier() : super('');

  void updateSearchForA(String newSearchForA) {
    state = newSearchForA;
  }
}

final searchForAProvider = StateNotifierProvider<SearchForANotifier, String>((ref) {
  return SearchForANotifier();
});

class SearchBoxForA extends ConsumerWidget {

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchForANotifier = ref.watch(searchForAProvider.notifier);
    return TextField(
      onChanged: (value) => searchForANotifier.updateSearchForA(value),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(10,5,0,5),
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(),
      ),
    );
  }
}

class PostForA {
  final String id;
  final int number;
  final String eng;
  final String? jpn;

  PostForA({required this.id, required this.number, required this.eng, this.jpn});

  factory PostForA.fromJson(Map<String, dynamic> json, {required String id}) {
    return PostForA(
      id: id,
      number: json['number'] as int,
      eng: json['eng'] as String,
      jpn: json['jpn'] as String?,
    );
  }
}

final favoritesForAProvider = StateProvider<List<String>>((ref) => []);
final favoritePostProvider = StateProvider.family<bool, String>((ref, postId) => false);
final favoritesForBacklogProvider = StateProvider<List<int>>((ref) => []);
final favoritesForDoneProvider = StateProvider<List<int>>((ref) => []);

class FavoritePostWidget extends ConsumerWidget {
  final PostForA post;

  FavoritePostWidget({required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorited = ref.watch(favoritePostProvider(post.id)); // ここでIDを使用

    return Container(
      margin: EdgeInsets.fromLTRB(8, 0, 8, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(width: 1, color: Colors.black),
      ),
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              final currentState = ref.read(favoritePostProvider(post.id).notifier).state;
              final currentFavorites = ref.read(favoritesForAProvider);

              if (currentState) {
                final newFavorites = currentFavorites.where((id) => id != post.id).toList();
                ref.read(favoritesForAProvider.notifier).state = newFavorites;
              } else {
                final newFavorites = [...currentFavorites, post.id];
                ref.read(favoritesForAProvider.notifier).state = newFavorites;
              }

              ref.read(favoritePostProvider(post.id).notifier).state = !currentState;
            },
            child: Container(
              margin: EdgeInsets.fromLTRB(2, 1.6, 0, 0),
              width: 26,
              child: Icon(
                isFavorited ? Icons.star : Icons.star,
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
                child: Text(
                  post.eng,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.indigo,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(30,0,6,5),
                child: Text(
                  post.jpn ?? '',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PostsListView extends StatelessWidget {
  final AsyncValue<List<PostForA>> filteredItemsForAAsyncValue;

  PostsListView({required this.filteredItemsForAAsyncValue});

  @override
  Widget build(BuildContext context) {
    return filteredItemsForAAsyncValue.when(
      data: (filteredPostsForA) {
        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: filteredPostsForA.length,
          itemBuilder: (context, index) {
            final post = filteredPostsForA[index];
            return FavoritePostWidget(post: post);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(error.toString())),
    );
  }
}

class CreateAppBarForA extends CreateAppBar implements PreferredSizeWidget {
  const CreateAppBarForA({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
        backgroundColor: Colors.red,
        leading: Icon(Icons.menu),
        title: Container(
          width: 300,
          height: 40,
          child: SearchBoxForA(),
        )
    );
  }
}

class TextPostScreen extends ConsumerWidget {
  const TextPostScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterForA = ref.watch(selectedDropdownItemForAProvider);
    final filteredItemsForAAsyncValue = ref.watch(filteredItemsForAProvider(filterForA));

    return Scaffold(
      backgroundColor: Colors.deepOrange[50],
      appBar: CreateAppBarForA(),
      body: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Container(
                margin: EdgeInsets.fromLTRB(32, 16, 0, 0),
                child: Text('How do you say this in Japanese?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ExpansionTile(
                title: Text(''),
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(8, 0, 8, 10),
                    height: 140,
                    width: 800,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        width: 2,
                        color: Colors.black,
                      ),
                    ),
                    child: TextField(
                      controller: ref.watch(textEditingControllerProvider),
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(10, 36, 0, 36),
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 320,
                right: 20,
                top: 146,
                bottom: 10,
                child: IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: () async {
                    final textToSend = ref.read(textEditingControllerProvider).text;
                    if (textToSend.isNotEmpty) {
                      await ref.read(textSendingProvider);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Text sent successfully')),
                      );
                      ref.read(textEditingControllerProvider).clear();
                    }
                  },
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  margin: EdgeInsets.fromLTRB(10, 0, 100, 0),
                  child: Text('All your requests'),
                ),
              ),
              CreateDropdown(),
            ],
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.refresh(postsForAProvider);
              },
              child: PostsListView(filteredItemsForAAsyncValue: filteredItemsForAAsyncValue),
            ),
          ),
        ],
      ),
    );
  }
}


