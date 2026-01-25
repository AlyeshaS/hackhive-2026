import 'package:flutter/material.dart';
import 'preferences_service.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  final PreferencesService _preferencesService = PreferencesService();
  final Map<String, List<String>> _selected = {
    'food': [],
    'outing': [],
    'interests': [],
    'location': [],
  };
  final Map<String, TextEditingController> _customControllers = {
    'food': TextEditingController(),
    'outing': TextEditingController(),
    'interests': TextEditingController(),
    'location': TextEditingController(),
  };

  final Map<String, List<String>> _options = {
    'food': [
      'Sushi',
      'Pizza',
      'Brunch',
      'BBQ',
      'Vegan',
      'Desserts',
      'Seafood',
      'Tapas',
      'Steakhouse',
      'Street Food',
    ],
    'outing': [
      'Hiking',
      'Board Games',
      'Art Gallery',
      'Live Music',
      'Escape Room',
      'Picnic',
      'Movie Night',
      'Cooking Class',
      'Bowling',
      'Mini Golf',
    ],
    'interests': [
      'Travel',
      'Photography',
      'Dancing',
      'Reading',
      'Sports',
      'Crafting',
      'Tech',
      'Gardening',
      'Yoga',
      'Comedy',
    ],
    'location': [
      'Downtown',
      'Nature',
      'Beach',
      'Mountains',
      'Suburbs',
      'Historic Sites',
      'Theme Park',
      'Local Cafe',
      'Rooftop',
      'Park',
    ],
  };

  Widget _buildChips(String category) {
    return Wrap(
      spacing: 8,
      children: [
        ..._options[category]!.map(
          (option) => FilterChip(
            label: Text(option),
            selected: _selected[category]!.contains(option),
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  _selected[category]!.add(option);
                } else {
                  _selected[category]!.remove(option);
                }
              });
            },
            selectedColor: const Color(0x3396616B),
            checkmarkColor: Colors.white,
            backgroundColor: const Color(0xFFFFEAD0),
            side: const BorderSide(color: Color(0xFF96616B)),
            selectedShadowColor: Colors.transparent,
            shadowColor: Colors.transparent,
          ),
        ),
        ActionChip(
          label: const Text('Add your own'),
          avatar: const Icon(Icons.add),

          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(
                  'Add your own to ${category[0].toUpperCase()}${category.substring(1)}',
                ),
                content: TextField(
                  controller: _customControllers[category],
                  decoration: const InputDecoration(hintText: 'Type here'),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      final value = _customControllers[category]!.text.trim();
                      if (value.isNotEmpty) {
                        setState(() {
                          _selected[category]!.add(value);
                          _options[category]!.add(value);
                        });
                        _customControllers[category]!.clear();
                      }
                      Navigator.pop(context);
                    },
                    child: const Text('Add'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Let’s Get to Know You!')),
      body: Container(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Pick what you both love! Select as many as you like, or add your own.',

              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              'Favorite Foods',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            _buildChips('food'),
            const SizedBox(height: 24),
            Text(
              'Type of Outing',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            _buildChips('outing'),
            const SizedBox(height: 24),
            Text(
              'Interests',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            _buildChips('interests'),
            const SizedBox(height: 24),
            Text(
              'Preferred Locations',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            _buildChips('location'),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF96616B),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.favorite),
              label: const Text(
                'Save & Continue',
                style: TextStyle(fontSize: 18),
              ),
              onPressed: () async {
                final prefs = {
                  'food': _selected['food'],
                  'outing': _selected['outing'],
                  'interests': _selected['interests'],
                  'location': _selected['location'],
                };
                await _preferencesService.savePreferences(prefs);
                Navigator.pushReplacementNamed(context, '/partner');
              },
            ),
          ],
        ),
      ),
    );
  }
}
