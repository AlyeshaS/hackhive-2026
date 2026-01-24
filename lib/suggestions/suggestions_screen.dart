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
  final SuggestionService _suggestionService = SuggestionService();
  List<Map<String, dynamic>> _suggestions = [
    // Placeholder suggestions; replace with Gemini API results
    {'id': '1', 'title': 'Sushi Night', 'desc': 'Enjoy sushi at a local spot.'},
    {'id': '2', 'title': 'Hiking Adventure', 'desc': 'Explore a scenic trail.'},
    {
      'id': '3',
      'title': 'Movie Marathon',
      'desc': 'Watch your favorite movies together.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Date Suggestions')),
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.7,
          child: CardSwiper(
            cardsCount: _suggestions.length,
            numberOfCardsDisplayed: 3,
            cardBuilder: (context, index, _, _) {
              final suggestion = _suggestions[index];
              return Card(
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
                  )
                  as Widget;
            },
            onSwipe: (previousIndex, currentIndex, direction) async {
              final suggestion = _suggestions[previousIndex];
              if (direction == CardSwiperDirection.right) {
                await _suggestionService.swipeSuggestion(
                  suggestion['id'],
                  true,
                );
              } else if (direction == CardSwiperDirection.left) {
                await _suggestionService.swipeSuggestion(
                  suggestion['id'],
                  false,
                );
              }
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
