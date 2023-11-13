import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:project_d/dropdown.dart';
import 'package:project_d/searchbox.dart';
import 'package:project_d/main.dart';
import 'package:project_d/page_b.dart';

final textSendingProvider = FutureProvider<void>((ref) async {
  final text = ref.read(textEditingControllerProvider).text;
  final serverUrl = 'http://192.168.1.124:3000/myPosts';

  if (text.isNotEmpty) {
    final response = await http.post(
      Uri.parse(serverUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'text': text}),
    );

    if (response.statusCode == 200) {
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
  final response = await http.get(Uri.parse('http://192.168.1.124:3000/allItems'));
  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    final List<dynamic> postsData = data['myPosts'];
    final List<PostForA> myPosts = postsData.map((item) => PostForA.fromJson(item)).toList();
    return myPosts;
  } else {
    throw Exception('Failed to load posts: ${response.statusCode}');
  }
});

final filteredItemsForAProvider = FutureProvider.family<List<PostForA>, String>((ref, filter) async {
  final response = await http.get(Uri.parse('http://192.168.1.124:3000/allItems'));
  final selectedItem = ref.watch(selectedDropdownItemProvider);
  final search = ref.watch(searchProvider);

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    final List<dynamic> postsData = data['myPosts'];
    final List<PostForA> myPosts = postsData.map((item) => PostForA.fromJson(item)).toList();

    List<PostForA> filteredPosts = myPosts;

    // Dropdownフィルターの適用
    if (selectedItem == 'Stars') {
      final favorites = ref.watch(favoritesProvider);
      filteredPosts = filteredPosts.where((post) => favorites.contains(post.myNumber)).toList();
    }

    // 検索フィルターの適用
    if (search.isNotEmpty) {
      filteredPosts = filteredPosts.where((post) => post.myTitle.toLowerCase().contains(search.toLowerCase())).toList();
    }

    return filteredPosts;
  } else {
    throw Exception('Failed to load posts');
  }
});

class SearchForANotifier extends StateNotifier<String> {
  SearchForANotifier() : super('');

  void updateSearchForA(String newSearch) {
    state = newSearch;
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
  final int myNumber;
  final String myTitle;
  final String myJpn;

  PostForA({required this.myNumber, required this.myTitle, required this.myJpn});

  factory PostForA.fromJson(Map<String, dynamic> json) {
    final myNumber = json['myNumber'] as int;
    final myTitle = json['myTitle'] as String;
    final myJpn = json['myJpn'] as String;

    return PostForA(
      myNumber: myNumber,
      myTitle: myTitle,
      myJpn: myJpn,
    );
  }
}

final favoritesForAProvider = StateProvider<List<int>>((ref) => []);

class TextPostScreen extends ConsumerWidget {
  const TextPostScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterForA = ref.watch(selectedDropdownItemForAProvider);
    final filteredItemsForAAsyncValue = ref.watch(filteredItemsForAProvider(filterForA));
    final favoritesForA = ref.watch(favoritesForAProvider);

    return Column(
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
            child: Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      ref.refresh(postsForAProvider);
                    },
                    child: filteredItemsForAAsyncValue.when(
                      data: (filteredPosts) {
                        return ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: filteredPosts.length,
                          itemBuilder: (context, index) {
                            final post = filteredPosts[index];
                            final isFavorited = favoritesForA.contains(post.myNumber);
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
                                      ref.read(favoritesForAProvider.notifier).update((state) {
                                        return isFavorited
                                        ? state.where((n) => n != post.myNumber).toList()
                                        : [...state, post.myNumber];
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
                                      child: Text(post.myTitle,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.indigo,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(30,0,6,5),
                                      child: Text(post.myJpn,
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
        ),
      ],
    );
  }
}