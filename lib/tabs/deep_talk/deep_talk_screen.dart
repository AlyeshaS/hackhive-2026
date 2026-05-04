import 'package:flutter/material.dart';
import 'deep_talk_service.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import '../../gemini_service.dart';

class DeepTalkScreen extends StatefulWidget {
  const DeepTalkScreen({super.key});

  @override
  State<DeepTalkScreen> createState() => _DeepTalkScreenState();
}

class _DeepTalkScreenState extends State<DeepTalkScreen> {
  final DeepTalkService _service = DeepTalkService();
  List<Map<String, dynamic>> _topics = [];
  // Removed completed topics tracking
  int _currentIndex = 0;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _generateMoreTopics() async {
    setState(() => _loading = true);
    final topics = await _service.generateAndReplaceTopics();
    setState(() {
      _topics = topics;
      _currentIndex = 0;
      _loading = false;
    });
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    final topics = await _service.getOrGenerateTopics();
    setState(() {
      _topics = topics;
      _loading = false;
    });
  }

  // Removed mark as complete logic

  // Removed completed topics modal

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Deep Talk')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
            child: ElevatedButton(
              onPressed: _generateMoreTopics,
              style:
                  ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF96616B), // pink background
                    foregroundColor: Colors.white, // text color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    elevation: 2,
                  ).copyWith(
                    surfaceTintColor: WidgetStateProperty.all(Colors.white),
                  ),
              child: const Text(
                'Generate More Cards',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,

                  fontSize: 16,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: _loading
                  ? const CircularProgressIndicator()
                  : _topics.isEmpty
                  ? const Text('No topics yet.')
                  : SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: Card(
                        color: const Color(0xFFFFEAD0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(
                            color: Color(0xFF96616B),
                            width: 4,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Topic ${_currentIndex + 1} of ${_topics.length}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      child: Text(
                                        _topics[_currentIndex]['topic'],
                                        style: const TextStyle(fontSize: 22),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.arrow_left,
                                        size: 32,
                                      ),
                                      onPressed: _currentIndex > 0
                                          ? () =>
                                                setState(() => _currentIndex--)
                                          : null,
                                    ),
                                    const SizedBox(width: 32),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.arrow_right,
                                        size: 32,
                                      ),
                                      onPressed:
                                          _currentIndex < _topics.length - 1
                                          ? () =>
                                                setState(() => _currentIndex++)
                                          : null,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
