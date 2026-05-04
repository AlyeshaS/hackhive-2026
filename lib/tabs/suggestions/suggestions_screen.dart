import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'suggestion_service.dart';
import '../../gemini_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SuggestionsScreen extends StatefulWidget {
  const SuggestionsScreen({super.key});

  @override
  State<SuggestionsScreen> createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends State<SuggestionsScreen>
    with TickerProviderStateMixin {
  /// Fetches all suggestions and their swipe status from Firestore, and updates the yes/no/skip lists for the panel.
  Future<void> fetchSwipedSuggestionsForPanel() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final allSuggestionsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('suggestions')
        .get();
    _yes.clear();
    _no.clear();
    _skip.clear();
    for (final doc in allSuggestionsSnapshot.docs) {
      String cleanTitle = doc['title'];
      String cleanDesc = doc['desc'];
      if (cleanTitle.startsWith('**')) {
        cleanTitle = cleanTitle.replaceFirst(RegExp(r'^\*\*+'), '').trim();
      }
      if (cleanDesc.startsWith('**')) {
        cleanDesc = cleanDesc.replaceFirst(RegExp(r'^\*\*+'), '').trim();
      }
      final suggestion = {
        'id': doc['id'],
        'title': cleanTitle,
        'desc': cleanDesc,
      };
      final action = doc['swipe'];
      if (action == "yes") {
        _yes.add(suggestion);
      } else if (action == "no") {
        _no.add(suggestion);
      } else if (action == "skip") {
        _skip.add(suggestion);
      }
    }
    setState(() {});
  }

  // Move _matched and _checkAndStoreMatch to the top of the class
  List<Map<String, dynamic>> _matched = [];

  Future<void> _checkAndStoreMatch(Map<String, dynamic> suggestion) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final partnerUid = await _getPartnerUid();
    if (partnerUid == null) return;
    // Check if partner swiped 'yes' on this suggestion (support both string and map for swipe)
    final partnerSuggestionDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(partnerUid)
        .collection('suggestions')
        .doc(suggestion['id'])
        .get();
    final partnerSwipe = partnerSuggestionDoc.data()?['swipe'];
    if (partnerSuggestionDoc.exists && partnerSwipe == 'yes') {
      // Save match for both users using SuggestionService for current user
      await _suggestionService.saveMatchedSuggestion(
        suggestion['id'],
        suggestion,
      );
      // Save for partner user (direct Firestore, since SuggestionService uses current user)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(partnerUid)
          .collection('matched_suggestions')
          .doc(suggestion['id'])
          .set(suggestion);
      setState(() {
        if (!_matched.any((s) => s['id'] == suggestion['id'])) {
          _matched.add(suggestion);
        }
      });
    }
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
    // Fetch partner's suggestions if partnerEmail exists
    String? partnerUid;
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final userData = userDoc.data();
    if (userData != null &&
        userData['partnerEmail'] != null &&
        userData['partnerEmail'] != '') {
      final partnerQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: userData['partnerEmail'])
          .get();
      if (partnerQuery.docs.isNotEmpty) {
        partnerUid = partnerQuery.docs.first.id;
      }
    }
    List<Map<String, dynamic>> partnerSuggestions = [];
    if (partnerUid != null) {
      final partnerSuggestionsSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(partnerUid)
          .collection('suggestions')
          .get();
      partnerSuggestions = partnerSuggestionsSnap.docs
          .map(
            (doc) => {
              'id': doc['id'],
              'title': doc['title'],
              'desc': doc['desc'],
            },
          )
          .toList();
    }
    // Get fresh Gemini suggestions with timeout
    final interests = await _getUserInterests();
    List<Map<String, dynamic>> geminiSuggestions = [];
    try {
      geminiSuggestions = await _geminiService
          .generateDateSuggestions(interests)
          .timeout(const Duration(seconds: 15));
    } on TimeoutException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('AI is taking too long. Please try again later.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load Gemini suggestions: $e')),
        );
      }
    }
    // Merge and deduplicate by id
    final allSuggestionsMap = <String, Map<String, dynamic>>{};
    for (final s in geminiSuggestions) {
      allSuggestionsMap[s['id']] = s;
    }
    for (final s in partnerSuggestions) {
      allSuggestionsMap[s['id']] = s;
    }
    final allSuggestions = allSuggestionsMap.values.toList();
    // Save all displayed suggestions for the current user
    for (final suggestion in allSuggestions) {
      // Clean '**' from start if present
      String cleanTitle = suggestion['title'];
      String cleanDesc = suggestion['desc'];
      if (cleanTitle.startsWith('**')) {
        cleanTitle = cleanTitle.replaceFirst(RegExp(r'^\*\*+'), '').trim();
      }
      if (cleanDesc.startsWith('**')) {
        cleanDesc = cleanDesc.replaceFirst(RegExp(r'^\*\*+'), '').trim();
      }
      final cleanSuggestion = {
        ...suggestion,
        'title': cleanTitle,
        'desc': cleanDesc,
      };
      await _suggestionService.saveSuggestion(
        cleanSuggestion['id'],
        cleanSuggestion,
      );
    }
    setState(() {
      _suggestions = allSuggestions.map((s) {
        String cleanTitle = s['title'];
        String cleanDesc = s['desc'];
        if (cleanTitle.startsWith('**')) {
          cleanTitle = cleanTitle.replaceFirst(RegExp(r'^\*\*+'), '').trim();
        }
        if (cleanDesc.startsWith('**')) {
          cleanDesc = cleanDesc.replaceFirst(RegExp(r'^\*\*+'), '').trim();
        }
        return {...s, 'title': cleanTitle, 'desc': cleanDesc};
      }).toList();
      _loading = false;
    });
  }

  Future<String?> _getPartnerUid() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final userData = userDoc.data();
    if (userData == null ||
        userData['partnerEmail'] == null ||
        userData['partnerEmail'] == '') {
      return null;
    }
    final partnerQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: userData['partnerEmail'])
        .get();
    if (partnerQuery.docs.isEmpty) return null;
    return partnerQuery.docs.first.id;
  }

  final List<Map<String, dynamic>> _yes = [];
  final List<Map<String, dynamic>> _no = [];
  final List<Map<String, dynamic>> _skip = [];

  void _showSwipedCards() async {
    await fetchSwipedSuggestionsForPanel();
    await _loadMatchedSuggestions();
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
                Tab(text: 'Matched'),
              ],
            ),
            SizedBox(
              height: 300,
              child: TabBarView(
                children: [
                  _buildCardList(_yes),
                  _buildCardList(_no),
                  _buildCardList(_matched),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadMatchedSuggestions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final matchSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('matched_suggestions')
        .get();
    setState(() {
      _matched = matchSnap.docs
          .map(
            (doc) => {
              'id': doc['id'],
              'title': doc['title'],
              'desc': doc['desc'],
            },
          )
          .toList();
    });
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
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text(
                        'Generate More',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      style:
                          ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF96616B),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            elevation: 2,
                          ).copyWith(
                            surfaceTintColor: WidgetStateProperty.all(
                              Colors.white,
                            ),
                          ),
                      onPressed: _loading
                          ? null
                          : () async {
                              await _loadSuggestions(refresh: true);
                            },
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 1.0),
                    child: Text(
                      'You can swipe or click the buttons below.',
                      style: TextStyle(fontSize: 15, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height * 0.42,
                    child: CardSwiper(
                      cardsCount: _suggestions.length,
                      numberOfCardsDisplayed: (_suggestions.length < 3)
                          ? _suggestions.length
                          : 3,
                      cardBuilder: (context, index, _, __) {
                        if (index < 0 || index >= _suggestions.length) {
                          return null;
                        }
                        final suggestion = _suggestions[index];
                        return Card(
                          color: const Color(
                            0xFFFFEAD0,
                          ), // soft peach (white-ish)
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(
                              color: Color(0xFF96616B), // mauve border
                              width: 3,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Text(
                                  suggestion['title'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Text(
                                  suggestion['desc'],
                                  style: const TextStyle(fontSize: 14),
                                  textAlign: TextAlign.center,
                                ),
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
                            'yes',
                          );
                          await _checkAndStoreMatch(suggestion);
                        } else if (direction == CardSwiperDirection.right) {
                          _no.add(suggestion);
                          await _suggestionService.swipeSuggestion(
                            suggestion['id'],
                            'no',
                          );
                        } else {
                          _skip.add(suggestion);
                          await _suggestionService.swipeSuggestion(
                            suggestion['id'],
                            'skip',
                          );
                        }
                        setState(() {
                          if (_suggestions.isNotEmpty) {
                            _suggestions.removeAt(0);
                          }
                        });
                        if (_suggestions.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('No more suggestions!'),
                            ),
                          );
                        }
                        return false;
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 16,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: _suggestions.isEmpty
                            ? null
                            : () async {
                                final suggestion = _suggestions.first;
                                _yes.add(suggestion);
                                await _suggestionService.swipeSuggestion(
                                  suggestion['id'],
                                  'yes',
                                );
                                await _checkAndStoreMatch(suggestion);
                                setState(() {
                                  if (_suggestions.isNotEmpty) {
                                    _suggestions.removeAt(0);
                                  }
                                });
                                if (_suggestions.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('No more suggestions!'),
                                    ),
                                  );
                                }
                              },
                        icon: const Icon(Icons.check),
                        label: const Text('Yes'),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: _suggestions.isEmpty
                            ? null
                            : () async {
                                final suggestion = _suggestions.first;
                                _no.add(suggestion);
                                await _suggestionService.swipeSuggestion(
                                  suggestion['id'],
                                  'no',
                                );
                                setState(() {
                                  if (_suggestions.isNotEmpty) {
                                    _suggestions.removeAt(0);
                                  }
                                });
                                if (_suggestions.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('No more suggestions!'),
                                    ),
                                  );
                                }
                              },
                        icon: const Icon(Icons.close),
                        label: const Text('No'),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
