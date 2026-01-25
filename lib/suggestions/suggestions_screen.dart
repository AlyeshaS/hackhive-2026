import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'suggestion_service.dart';
import 'gemini_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SuggestionsScreen extends StatefulWidget {
  const SuggestionsScreen({super.key});

  @override
  State<SuggestionsScreen> createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends State<SuggestionsScreen>
    with TickerProviderStateMixin {
  // Move _matched and _checkAndStoreMatch to the top of the class
  List<Map<String, dynamic>> _matched = [];

  Future<void> _checkAndStoreMatch(Map<String, dynamic> suggestion) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final partnerUid = await _getPartnerUid();
    if (partnerUid == null) return;
    final swipeDoc = await FirebaseFirestore.instance
        .collection('swipes')
        .doc(partnerUid)
        .collection('suggestions')
        .doc(suggestion['id'])
        .get();
    if (swipeDoc.exists && swipeDoc.data()?['action'] == 'yes') {
      // Store match for both users under /matches/{coupleId}/suggestions
      final coupleId = user.uid.compareTo(partnerUid) < 0
          ? '${user.uid}_$partnerUid'
          : '${partnerUid}_${user.uid}';
      await FirebaseFirestore.instance
          .collection('matches')
          .doc(coupleId)
          .collection('suggestions')
          .doc(suggestion['id'])
          .set(suggestion);
      // Optionally update local state
      setState(() {
        if (!_matched.any((s) => s['id'] == suggestion['id'])) {
          _matched.add(suggestion);
        }
      });
    }
  }

  Future<void> _recordSwipe(String suggestionId, String action) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance
        .collection('swipes')
        .doc(user.uid)
        .collection('suggestions')
        .doc(suggestionId)
        .set({'action': action, 'timestamp': FieldValue.serverTimestamp()});
  }

  late final SuggestionService _suggestionService = SuggestionService();
  List<Map<String, dynamic>> _suggestions = [];
  bool _loading = false;
  final GeminiService _geminiService = GeminiService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only load if not already loading or loaded
    if (!_loading && _suggestions.isEmpty) {
      _loadSuggestions(refresh: true);
    }
  }

  Future<List<String>> _getUserInterests() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];
    final doc = await FirebaseFirestore.instance
        .collection('preferences')
        .doc(user.uid)
        .get();
    final data = doc.data();
    if (data == null || data['interests'] == null) return [];
    return List<String>.from(data['interests']);
  }

  Future<void> _loadSuggestions({bool refresh = false}) async {
    setState(() {
      _loading = true;
    });
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _loading = false;
      });
      return;
    }
    final doc = await FirebaseFirestore.instance
        .collection('suggestions')
        .doc(user.uid)
        .get();
    if (doc.exists && !refresh) {
      final data = doc.data();
      if (data != null && data['suggestions'] != null) {
        setState(() {
          _suggestions = List<Map<String, dynamic>>.from(data['suggestions']);
          _loading = false;
        });
        return;
      }
    }
    // If not found or refresh, call Gemini
    final interests = await _getUserInterests();
    try {
      final aiSuggestions = await _geminiService.generateDateSuggestions(
        interests,
      );
      await FirebaseFirestore.instance
          .collection('suggestions')
          .doc(user.uid)
          .set({'suggestions': aiSuggestions});
      setState(() {
        _suggestions = aiSuggestions;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load suggestions: $e')),
        );
      }
    }
  }

  Future<String?> _getPartnerUid() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    final doc = await FirebaseFirestore.instance
        .collection('partners')
        .doc(user.uid)
        .get();
    final data = doc.data();
    if (data == null || data['partnerUid'] == null) return null;
    return data['partnerUid'] as String;
  }

  final List<Map<String, dynamic>> _yes = [];
  final List<Map<String, dynamic>> _no = [];
  final List<Map<String, dynamic>> _skip = [];

  void _showSwipedCards() {
    showModalBottomSheet(
      context: context,
      builder: (context) => DefaultTabController(
        length: 4,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Yes'),
                Tab(text: 'No'),
                Tab(text: 'Skip'),
                Tab(text: 'Matched'),
              ],
            ),
            SizedBox(
              height: 300,
              child: TabBarView(
                children: [
                  _buildCardList(_yes),
                  _buildCardList(_no),
                  _buildCardList(_skip),
                  _buildCardList(_matched),
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
        child: _loading
            ? const CircularProgressIndicator()
            : _suggestions.isEmpty
            ? const Text('No suggestions yet.')
            : SizedBox(
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
                    final suggestion = _suggestions[previousIndex];
                    if (direction == CardSwiperDirection.left) {
                      _yes.add(suggestion);
                      await _suggestionService.swipeSuggestion(
                        suggestion['id'],
                        true,
                      );
                      await _recordSwipe(suggestion['id'], 'yes');
                      await _checkAndStoreMatch(suggestion);
                    } else if (direction == CardSwiperDirection.right) {
                      _no.add(suggestion);
                      await _suggestionService.swipeSuggestion(
                        suggestion['id'],
                        false,
                      );
                      await _recordSwipe(suggestion['id'], 'no');
                    } else {
                      _skip.add(suggestion);
                      await _recordSwipe(suggestion['id'], 'skip');
                    }
                    setState(() {});
                    if (previousIndex == _suggestions.length - 1) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No more suggestions!')),
                      );
                    }
                    return false;
                  },
                ),
              ),
      ),
    );
  }
}
