import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_d/page_a.dart';
import 'package:project_d/page_b.dart';
import 'package:project_d/page_c.dart';
import 'package:project_d/searchbox.dart';

final combinedItemsProvider = FutureProvider.family<List<dynamic>, String>((ref, filter) async {
  final response = await http.get(Uri.parse('http://192.168.1.124:3000/allItems'));

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonData = json.decode(response.body);
    final searchQuery = ref.watch(searchProvider).toLowerCase();

    final List<dynamic> myPostsForBacklogData = jsonData['myPostsForBacklog'] ?? [];
    final List<dynamic> myPostsForDoneData = jsonData['myPostsForDone'] ?? [];

    // FlashCardのデータを取得
    final AsyncValue<List<FlashCard>> flashCardsAsyncValue = ref.watch(flashCardProvider(searchQuery.isEmpty ? null : searchQuery));
    final List<FlashCard> flashCards = flashCardsAsyncValue.when(
      data: (cards) => cards,
      loading: () => <FlashCard>[],
      error: (_, __) => <FlashCard>[],
    );

    final List<dynamic> combinedItems = [
      ...myPostsForBacklogData.map((item) => PostForA.fromJson(item, id: '${item['number']}-${item['eng'].hashCode}')),
      ...myPostsForDoneData.map((item) => PostForA.fromJson(item, id: '${item['number']}-${item['eng'].hashCode}')),
      ...flashCards,
    ];

    // フィルタリングと検索
    return combinedItems.where((item) {
      if (item is PostForA) {
        return (filter == 'All' || item.id.contains(filter)) &&
            (item.eng.toLowerCase().contains(searchQuery) || (item.jpn ?? '').toLowerCase().contains(searchQuery));
      } else if (item is FlashCard) {
        return item.word.toLowerCase().contains(searchQuery) ||
            item.meaning.toLowerCase().contains(searchQuery) ||
            item.example.toLowerCase().contains(searchQuery) ||
            item.engExample.toLowerCase().contains(searchQuery);
      } else {
        return true;
      }
    }).toList();
  } else {
    throw Exception('Failed to load items');
  }
});

final flashCardProvider = FutureProvider.family<List<FlashCard>, String?>((ref, searchQuery) async {
  final flashCardService = ref.watch(flashCardServiceProvider);
  return flashCardService.fetchFlashCards(searchQuery: searchQuery);
});

final flashCardServiceProvider = Provider((ref) {
  return FlashCardService();
});

class FlashCardService {
  Future<List<FlashCard>> fetchFlashCards({String? searchQuery}) async {
    final response = await http.get(Uri.parse('http://192.168.1.124:3000/flashCards'));

    if (response.statusCode == 200) {
      List<dynamic> flashCardsJson = jsonDecode(response.body);
      List<FlashCard> flashCards = flashCardsJson.map((json) => FlashCard.fromJson(json)).toList();

      if (searchQuery != null && searchQuery.isNotEmpty) {
        flashCards = flashCards.where((card) {
          return true;
        }).toList();
      }

      return flashCards;
    } else {
      throw Exception('Failed to load flash cards');
    }
  }
}
