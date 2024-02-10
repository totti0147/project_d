import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:project_d/CustomColor.dart';
import 'package:project_d/searchbox.dart';
import 'package:project_d/dropdown.dart';

final flashCardProvider = StateNotifierProvider<FlashCardNotifier, List<FlashCard>>((ref) {
  return FlashCardNotifier();
});

final filteredFlashCardsProvider = StateProvider<List<FlashCard>>((ref) {
  return [];
});

class FlashCardService {
  Future<List<FlashCard>> fetchFlashCards() async {
    final response = await http.get(Uri.parse('http://192.168.150.5:3000/flashCards'));

    if (response.statusCode == 200) {
      List<dynamic> flashCardsJson = jsonDecode(response.body);
      return flashCardsJson.map((json) => FlashCard.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load flash cards');
    }
  }
}

class FlashCardNotifier extends StateNotifier<List<FlashCard>> {
  FlashCardNotifier() : super([]);

  bool _fetched = false;

  // フラッシュカードのデータをフェッチするメソッド
  Future<void> fetchFlashCards() async {
    if (_fetched) return;

    final response = await http.get(Uri.parse('http://192.168.150.5:3000/flashCards'));
    if (response.statusCode == 200) {
      final List<FlashCard> flashCards = (jsonDecode(response.body) as List)
          .map((json) => FlashCard.fromJson(json))
          .toList();
      state = flashCards;
      _fetched = true;
    } else {
      throw Exception('Failed to load flash cards');
    }
  }

  Future<void> filterFlashCards(List<String> selectedTags) async {
    if (!_fetched) await fetchFlashCards();

    if (selectedTags.isEmpty) {
      state = state;
      return;
    }

    state = state.where((card) {
      final cardTags = card.tag.split(',').map((t) => t.trim()).toList();
      return selectedTags.every((tag) => cardTags.contains(tag));
    }).toList();
  }

  // 特定のフラッシュカードのStar状態を切り替えるメソッド
  void toggleStar(int cardNumber) {
    state = state.map((card) {
      if (card.number == cardNumber) {
        var updatedCard = card.copyWith(isStarred: !card.isStarred);
        return updatedCard;
      }
      return card;
    }).toList();
  }

  // 特定のフラッシュカードのLearned状態を切り替えるメソッド
  void toggleLearned(int cardNumber) {
    state = state.map((card) {
      if (card.number == cardNumber) {
        var updatedCard = card.copyWith(isLearned: !card.isLearned);
        return updatedCard;
      }
      return card;
    }).toList();
  }
}

class FlashCard {
  final int number;
  final String tag;
  final String word;
  final String meaning;
  final String synonymous;
  final String example;
  final String engExample;
  final String comment;
  final int useFrequency;
  final int level;
  final int casualLevel;
  final int formalLevel;
  bool isStarred;
  bool isLearned;

  FlashCard({
    required this.number,
    required this.tag,
    required this.word,
    required this.meaning,
    required this.synonymous,
    required this.example,
    required this.engExample,
    required this.comment,
    required this.useFrequency,
    required this.level,
    required this.casualLevel,
    required this.formalLevel,
    this.isStarred = false,
    this.isLearned = false,
  });

  // JSONからオブジェクトを生成するファクトリコンストラクタ
  factory FlashCard.fromJson(Map<String, dynamic> json) {
    return FlashCard(
      number: json['number'],
      tag: json['tag'],
      word: json['word'],
      meaning: json['meaning'],
      synonymous: json['synonymous'],
      example: json['example'],
      engExample: json['engExample'],
      comment: json['comment'],
      useFrequency: json['useFrequency'],
      level: json['level'],
      casualLevel: json['casualLevel'],
      formalLevel: json['formalLevel'],
      isStarred: json['isStarred'] ?? false,
      isLearned: json['isLearned'] ?? false,
    );
  }

  // FlashCardのコピーを生成し、特定のプロパティを変更するメソッド
  FlashCard copyWith({
    bool? isStarred,
    bool? isLearned,
  }) {
    return FlashCard(
      number: this.number,
      tag: this.tag,
      word: this.word,
      meaning: this.meaning,
      synonymous: this.synonymous,
      example: this.example,
      engExample: this.engExample,
      comment: this.comment,
      useFrequency: this.useFrequency,
      level: this.level,
      casualLevel: this.casualLevel,
      formalLevel: this.formalLevel,
      isStarred: isStarred ?? this.isStarred,
      isLearned: isLearned ?? this.isLearned,
    );
  }

  // Starの状態を切り替えるメソッド
  void toggleStar() {
    isStarred = !isStarred;
  }

  // Learnedの状態を切り替えるメソッド
  void toggleLearned() {
    isLearned = !isLearned;
  }
}

final currentPageProvider = StateProvider<int?>((ref) => null);
final dropdownValueProvider = StateProvider<String>((ref) => 'All');

final internalTagStateProvider = StateProvider<Map<String, bool>>((ref) => {
  'Often used': false,
  'Must': false,
  'Happy': false,
  'Cool': false,
  'Funny': false,
  'Great': false,
  'Excited': false,
  'Surprised': false,
  'Intellectual': false,
  'Sad': false
});

final externalTagStateProvider = StateProvider<Map<String, bool>>((ref) => {
  'Often used': false,
  'Must': false,
  'Happy': false,
  'Cool': false,
  'Funny': false,
  'Great': false,
  'Excited': false,
  'Surprised': false,
  'Intellectual': false,
  'Sad': false
});

final tagStateProvider = StateProvider.autoDispose<Map<String, bool>>((ref) {
  return {
    'Often used': false,
    'Must': false,
    'Happy': false,
    'Cool': false,
    'Funny': false,
    'Great': false,
    'Excited': false,
    'Surprised': false,
    'Intellectual': false,
    'Sad': false
  };
});

class CreateDropdownForC extends CreateDropdown {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 92,
      child: DropdownButton<String>(
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Colors.white
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.fromLTRB(0, 2, 10, 2),
        isDense: true,
        iconSize: 24,
        underline: Container(),
        dropdownColor: customRed,
        iconEnabledColor: Colors.white,
        value: ref.watch(dropdownValueProvider),
        items: const [
          DropdownMenuItem(
            child: Text('Sort'),
            value: 'Sort',
          ),
          DropdownMenuItem(
            child: Text('All'),
            value: 'All',
          ),
          DropdownMenuItem(
            child: Text('Stars'),
            value: 'Stars',
          ),
          DropdownMenuItem(
            child: Text('Learned'),
            value: 'Learned',
          ),
        ],
        onChanged: (String? newValue) {
          if (newValue != null) {
            ref.read(dropdownValueProvider.state).state = newValue;
            ref.read(currentPageProvider.state).state = null;
          }
        },
      ),
    );
  }
}

class CreateAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CreateAppBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
        backgroundColor: beige,
        leading: Icon(Icons.menu),
        title: Container(
          width: 300,
          height: 40,
          child: SearchBox(),
        )
    );
  }
}

class TagButtonsWidget extends ConsumerWidget {
  final FlashCard card;

  TagButtonsWidget({Key? key, required this.card}) : super(key: key);

  Widget _buildDialogButton(BuildContext context, WidgetRef ref, String tag) {
    // internalTagStateProviderを使ってダイアログ内のボタンの状態を把握
    final isTagSelected = ref.watch(internalTagStateProvider.state).state[tag] ?? false;
    return ElevatedButton(
      onPressed: () {
        ref.read(internalTagStateProvider.notifier).update((state) {
          var newState = {...state};
          newState[tag] = !isTagSelected; // ここでタグの状態を切り替え
          return newState;
        });
        (context as Element).markNeedsBuild(); // UIの更新をマーク
      },
      child: Text('#$tag'),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(
            isTagSelected ? Colors.grey : Colors.blue // 選択されたタグはグレー、それ以外はブルー
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var tags = card.tag.split(',').map((tag) => tag.trim()).toList();
    tags.add('Index'); // 'Index' タグを追加

    return Wrap(
      spacing: 8.0, // 水平方向のスペース
      children: tags.map((tag) {
        // externalTagStateProviderを使って外部のボタンの状態を把握
        final isTagSelected = ref.watch(externalTagStateProvider.state).state[tag] ?? false;
        return ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                  // 'Index'は常に特定の色を持ち、他は選択状態に応じて色を変える
                  return tag == 'Index' ? Colors.orange : (isTagSelected ? Colors.grey : Colors.white);
                }
            ),
            foregroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                  return tag == 'Index' ? Colors.white : (isTagSelected ? Colors.white : Colors.orange);
                }
            ),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2.0),
                    side: BorderSide(color: tag == 'Index' ? Colors.orange : Colors.orange, width: 1)
                )
            ),
            padding: MaterialStateProperty.all<EdgeInsets>(
              EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            ),
          ),
          onPressed: () {
            if (tag == 'Index') {
              showDialog(
                context: context,
                builder: (BuildContext dialogContext) {
                  return StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return AlertDialog(
                        title: Text('Select the tags you want to search and press the search button.'),
                        content: Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: [
                            ...ref.watch(internalTagStateProvider.state).state.keys.map((String tag) {
                              return _buildDialogButton(dialogContext, ref, tag);
                            }),
                            ElevatedButton(
                              onPressed: () {
                                final selectedTags = ref
                                    .read(internalTagStateProvider.state)
                                    .state
                                    .entries
                                    .where((entry) => entry.value)
                                    .map((entry) => entry.key)
                                    .toList();

                                ref.read(flashCardProvider.notifier).filterFlashCards(selectedTags);
                                Navigator.of(dialogContext).pop();
                                ref.read(dropdownValueProvider.state).state = 'Sort';
                              },
                              child: Text('Search'),
                              style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            } else {
              // 外部のタグボタンに対する処理
              ref.read(externalTagStateProvider.notifier).update((state) {
                var newState = {...state};
                newState[tag] = !isTagSelected; // ここで外部のタグ状態を切り替え
                return newState;
              });
            }
          },
          child: Text(
            tag == 'Index' ? 'Index' : '#$tag',
          ),
        );
      }).toList(),
    );
  }
}

class StarRating extends StatelessWidget {
  final int starCount;
  final Color color;
  final double size;

  const StarRating({Key? key, this.starCount = 5, this.color = Colors.yellow, this.size = 22.0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(starCount, (index) => Icon(
        Icons.star,
        color: color,
        size: size,
      )),
    );
  }
}

class FlashCardList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flashCards = ref.watch(flashCardProvider);
    final dropdownValue = ref.watch(dropdownValueProvider);

    List<FlashCard> filteredCards = flashCards;
    if (dropdownValue == 'Stars') {
      filteredCards = flashCards.where((card) => card.isStarred).toList();
    } else if (dropdownValue == 'Learned') {
      filteredCards = flashCards.where((card) => card.isLearned).toList();
    } else {
      filteredCards = flashCards.where((card) => !card.isLearned).toList();
    }

    return ListView.builder(
      itemCount: filteredCards.length,
      itemBuilder: (context, index) {
        final card = filteredCards[index];

        return GestureDetector(
          onTap: () {
            int tappedIndex = filteredCards.indexWhere((item) => item.number == card.number);
            ref.read(currentPageProvider.state).state = tappedIndex;
          },
          child: Container(
            margin: EdgeInsets.fromLTRB(8, 0, 8, 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(width: 1, color: Colors.black),
            ),
            child: Stack(
              children: [
                Container(
                  width: 26,
                  child: IconButton(
                    icon: Icon(
                      card.isStarred ? Icons.star : Icons.star,
                      size: 30,
                      color: card.isStarred ? Colors.yellow[800] : Colors.grey[400],
                    ),
                    onPressed: () {
                      ref.read(flashCardProvider.notifier).toggleStar(card.number);
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 36, 0, 0),
                  width: 26,
                  child: IconButton(
                    icon: Icon(
                      card.isLearned ? Icons.archive : Icons.archive_outlined,
                      size: 30,
                      color: card.isLearned ? Colors.red : Colors.grey[400],
                    ),
                    onPressed: () {
                      bool isCurrentlyLearned = card.isLearned;
                      ref.read(flashCardProvider.notifier).toggleLearned(card.number);

                      if (!isCurrentlyLearned) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('The card has moved to the Learned box.'))
                        );
                      }
                    },
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.fromLTRB(56, 8, 6, 0),
                      child: Text(
                        card.word,
                        style: TextStyle(
                          color: Colors.brown[800],
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(56, 6, 6, 5),
                      child: Text(
                        card.meaning,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 20,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(6, 4, 4, 0),
                      child: Text(
                        card.example,
                        style: TextStyle(
                          color: Colors.brown[800],
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(6, 4, 4, 4),
                      child: Text(
                        card.engExample,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class FlashCardPage extends ConsumerWidget {
  const FlashCardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(flashCardProvider.notifier).fetchFlashCards();

    final currentPage = ref.watch(currentPageProvider);

    return Scaffold(
      backgroundColor: deepBlue,
      appBar: CreateAppBar(),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(),
              ),
              CreateDropdownForC(),
            ],
          ),
          Expanded(
            child: currentPage == null
                ? FlashCardList()
                : PageViewWidget(currentPage: currentPage),
          ),
        ],
      ),
    );
  }
}

class PageViewWidget extends ConsumerWidget {
  final int currentPage;

  const PageViewWidget({Key? key, required this.currentPage}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final flashCards = ref.watch(flashCardProvider);
    final dropdownValue = ref.watch(dropdownValueProvider);

    List<FlashCard> filteredCards = flashCards;
    if (dropdownValue == 'Stars') {
      filteredCards = flashCards.where((card) => card.isStarred).toList();
    } else if (dropdownValue == 'Learned') {
      filteredCards = flashCards.where((card) => card.isLearned).toList();
    } else {
      filteredCards = flashCards.where((card) => !card.isLearned).toList();
    }

    final pageController = PageController(initialPage: currentPage);

    return PageView.builder(
      controller: pageController,
      itemCount: filteredCards.length,
      itemBuilder: (context, index) {
        final card = filteredCards[index];
        return Words(card: card);
      },
      onPageChanged: (index) {
        if (index < filteredCards.length) {
          final newCardNumber = filteredCards[index].number;
          ref.read(currentPageProvider.state).state = newCardNumber;
        }
      },
    );
  }
}

class Words extends ConsumerWidget {
  final FlashCard card;

  Words({Key? key, required this.card}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPage = ref.watch(currentPageProvider);

    return GestureDetector(
      onTap: () {
        if (currentPage == card.number) {
          ref.read(currentPageProvider.state).state = null;
        } else {
          ref.read(currentPageProvider.state).state = card.number;
        }
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(8, 0, 8, 8),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              width: 1,
              color: Colors.black,
            )
        ),
        child: buildCard(card, ref, context),
      ),
    );
  }

  Widget buildRatingRow(String label, int starCount, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start, // 子要素を左端に揃える
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 16),
          ),
        ),
        Expanded(
          child: StarRating(
              starCount: starCount, color: color
          ),
        ),
        SizedBox(width: 140),
      ],
    );
  }

  Widget buildCard(FlashCard card, WidgetRef ref, BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: Colors.grey[100],
        child: Stack(
          children: [
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          card.isStarred ? Icons.star : Icons.star,
                          size: 30,
                          color: card.isStarred ? Colors.yellow[800] : Colors.grey[400],
                        ),
                        onPressed: () => ref.read(flashCardProvider.notifier).toggleStar(card.number),
                      ),
                      ElevatedButton.icon(
                        icon: Icon(Icons.archive_outlined),
                        label: Text('Learned'),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              card.isLearned ? Colors.grey : Colors.red
                          ),
                        ),
                        onPressed: () {
                          ref.read(flashCardProvider.notifier).toggleLearned(card.number);

                          if (!card.isLearned) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('The card has moved to the Learned box.'))
                            );
                          }

                          final dropdownValue = ref.watch(dropdownValueProvider);
                          if (dropdownValue != 'Stars') {
                            ref.read(currentPageProvider.state).state = null;
                          }
                        },
                      ),
                    ],
                  ),
                  Center(
                    child: Text(
                      card.word ?? 'Unknown',
                      style: TextStyle(
                          color: Colors.brown[800],
                          fontSize: 30,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    color: beige,
                    child: Container(
                      margin: EdgeInsets.fromLTRB(4, 0, 4, 0),
                      child: Text('Meaning',
                        style: TextStyle(
                            color: deepBlue,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      card.meaning ?? 'No meaning available',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 22,
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    color: beige,
                    child: Container(
                      margin: EdgeInsets.fromLTRB(4, 0, 4, 0),
                      child: Text('Synonymous',
                        style: TextStyle(
                            color: deepBlue,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      card.synonymous ?? 'No synonymous available',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 22,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(4, 0, 4, 0),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: beige,
                    ),
                    child: Text('Comment',
                      style: TextStyle(
                          color: deepBlue,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    width: double.infinity,
                    margin: EdgeInsets.fromLTRB(4, 0, 4, 4),
                    child: Text(
                      card.comment ?? 'No comment',
                      style: TextStyle(
                        color: Colors.brown[800],
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(10, 8, 10, 0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: 200),
                      child: TagButtonsWidget(card: card),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(8, 8, 8, 10),
                    child: Column(
                      children: [
                        buildRatingRow("Difficulty level: ", card.level ?? 0, Colors.amber),
                        buildRatingRow("Use Frequency: ", card.useFrequency ?? 0, Colors.teal),
                        buildRatingRow("Casual Level: ", card.casualLevel ?? 0, Colors.deepOrangeAccent),
                        buildRatingRow("Formal Level: ", card.formalLevel ?? 0, Colors.green),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.fromLTRB(4, 0, 4, 0),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.deepOrange[50],
                          ),
                          child: Text('Example',
                            style: TextStyle(color: Colors.brown[800]),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(4, 4, 4, 0),
                          child: Text(
                            card.example ?? 'No example',
                            style: TextStyle(
                                color: Colors.brown[800],
                                fontSize: 16
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.fromLTRB(4, 0, 4, 4),
                          child: Text(
                            card.engExample ?? 'No English example',
                            style: TextStyle(color: Colors.grey[600], fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]
            ),
          ],
        ),
      ),
    );
  }
}