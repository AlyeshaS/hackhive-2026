import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'suggestion_service.dart';

class SuggestionsScreen extends StatefulWidget {
  const SuggestionsScreen({super.key});

  @override
  State<SuggestionsScreen> createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends State<SuggestionsScreen>
    with TickerProviderStateMixin {
  late final SuggestionService _suggestionService = SuggestionService();
  final List<Map<String, dynamic>> _suggestions = [
    {'id': '1', 'title': 'Sushi Night', 'desc': 'Enjoy sushi at a local spot.'},
    {'id': '2', 'title': 'Hiking Adventure', 'desc': 'Explore a scenic trail.'},
    {
      'id': '3',
      'title': 'Movie Marathon',
      'desc': 'Watch your favorite movies together.',
    },
  ];
  final List<Map<String, dynamic>> _yes = [];
  final List<Map<String, dynamic>> _no = [];
  final List<Map<String, dynamic>> _skip = [];

  void _showSwipedCards() {
    showModalBottomSheet(
      context: context,
      builder: (context) => DefaultTabController(
        length: 3,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Yes'),
                Tab(text: 'No'),
                Tab(text: 'Skip'),
              ],
            ),
            SizedBox(
              height: 300,
              child: TabBarView(
                children: [
                  _buildCardList(_yes),
                  _buildCardList(_no),
                  _buildCardList(_skip),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardList(List<Map<String, dynamic>> cards) {
    if (cards.isEmpty) {
      return const Center(child: Text('No cards'));
    }
    return ListView(
      children: cards
          .map(
            (card) => ListTile(
              title: Text(card['title']),
              subtitle: Text(card['desc']),
            ),
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Date Suggestions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: 'View all swiped cards',
            onPressed: _showSwipedCards,
          ),
        ],
      ),
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.7,
          child: CardSwiper(
            cardsCount: _suggestions.length,
            numberOfCardsDisplayed: 3,
            cardBuilder: (context, index, _, __) {
              if (index < 0 || index >= _suggestions.length) return null;
              final suggestion = _suggestions[index];
              return Card(
                color: const Color(0xFFFFEAD0), // soft peach (white-ish)
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(
                    color: Color(0xFF96616B), // mauve border
                    width: 4,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      suggestion['title'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      suggestion['desc'],
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              );
            },
            onSwipe: (previousIndex, currentIndex, direction) async {
              // if (previousIndex == null) return;
              final suggestion = _suggestions[previousIndex];
              if (direction == CardSwiperDirection.left) {
                _yes.add(suggestion);
                await _suggestionService.swipeSuggestion(
                  suggestion['id'],
                  true,
                );
              } else if (direction == CardSwiperDirection.right) {
                _no.add(suggestion);
                await _suggestionService.swipeSuggestion(
                  suggestion['id'],
                  false,
                );
              } else {
                _skip.add(suggestion);
              }
              setState(() {});
              if (previousIndex == _suggestions.length - 1) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No more suggestions!')),
                );
              }
              return true;
            },
          ),
        ),
      ),
    );
  }
}
