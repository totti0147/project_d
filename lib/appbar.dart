import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class CreateAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CreateAppBar({Key? key}) : super(key: key);

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
          child: TextField(
            decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                )
            ),
          ),
        )
      );
    }
  }

  class SearchBar extends ConsumerWidget {

    @override
    Widget build(BuildContext context, WidgetRef ref) {

      return TextFormField(
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder()
        ),
        onChanged: (value) {
          //ref.read(searchKeywordProvider).state = value; 原因不明
        },
      );
    }
  }

  final searchKeywordProvider = StateProvider<String>((ref) => '');

  class SearchResultsList extends ConsumerWidget { //このSearchResultListをCalumnの中の表示させるところに入れる

    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final searchKeyword = ref.watch(searchKeywordProvider);
      final searchResults = getSearchResults(searchKeyword);
      return ListView.builder(
          itemCount: searchResults.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(searchResults[index]),
            );
          },
        );
      }

  List<String> getSearchResults(String keyword) {
    final List<String> allData = [];
    return allData.where((data) => data.toLowerCase().contains(keyword.toLowerCase())).toList();
  }
}

