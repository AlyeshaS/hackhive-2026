import 'package:flutter/material.dart';
import 'preferences_service.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  final PreferencesService _preferencesService = PreferencesService();
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _prefs = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Preferences')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Favorite Food'),
                onSaved: (v) => _prefs['food'] = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Type of Outing'),
                onSaved: (v) => _prefs['outing'] = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Budget'),
                onSaved: (v) => _prefs['budget'] = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Interests'),
                onSaved: (v) => _prefs['interests'] = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Preferred Location'),
                onSaved: (v) => _prefs['location'] = v,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  _formKey.currentState?.save();
                  await _preferencesService.savePreferences(_prefs);
                  Navigator.pushReplacementNamed(context, '/suggestions');
                },
                child: const Text('Save & Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
