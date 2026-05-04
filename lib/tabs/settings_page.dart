import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'preferences/preferences_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  User? user;
  String? partnerEmail;

  final PreferencesService _preferencesService = PreferencesService();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
    final data = userDoc.data();
    setState(() {
      user = currentUser;
      partnerEmail = data != null && data['partnerEmail'] != null
          ? data['partnerEmail'] as String
          : null;
      isLoading = false;
    });
  }

  Future<void> _addPartner() async {
    final emailController = TextEditingController();
    final partnerEmailInput = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Partner'),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(labelText: 'Partner Email'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, emailController.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (partnerEmailInput == null || partnerEmailInput.isEmpty) return;
    setState(() {
      isLoading = true;
    });
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception('Not signed in');
      final lowerPartnerEmail = partnerEmailInput.toLowerCase();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .set({'partnerEmail': lowerPartnerEmail}, SetOptions(merge: true));
      await _loadUserData();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to link partner: ${e.toString()}')),
      );
    }
  }

  Future<void> _removePartner() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Partner'),
        content: const Text(
          'Are you sure you want to remove your partner? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() {
      isLoading = true;
    });
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .set({'partnerEmail': ''}, SetOptions(merge: true));
    await _loadUserData();
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/welcome', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
        elevation: 0,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Section
                    const Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.2),
                          child: Icon(
                            Icons.person,
                            size: 36,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.displayName ?? '-',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user?.email ?? '-',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Partner Section
                    const Text(
                      'Link Partner',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: partnerEmail != null && partnerEmail!.isNotEmpty
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.link,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      partnerEmail ?? '',
                                      style: const TextStyle(fontSize: 17),
                                    ),
                                    const SizedBox(width: 10),
                                    IconButton(
                                      onPressed: _removePartner,
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.red,
                                      ),
                                      tooltip: 'Remove',
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Align(
                              alignment: Alignment.centerLeft,
                              child: ElevatedButton.icon(
                                onPressed: _addPartner,
                                icon: Icon(
                                  Icons.person_add,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                ),
                                label: const Text('Add Partner'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  foregroundColor: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 32),
                    // Interests Main Title
                    const Text(
                      'Interests',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    FutureBuilder<Map<String, dynamic>?>(
                      future: _preferencesService.getPreferences(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final prefs = snapshot.data ?? {};
                        return _CollapsiblePreferencesSections(prefs: prefs);
                      },
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Center(
              child: ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout, color: Colors.white, size: 18),
                label: const Text(
                  'Log Out',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CollapsiblePreferencesSections extends StatefulWidget {
  final Map<String, dynamic> prefs;
  const _CollapsiblePreferencesSections({required this.prefs});

  @override
  State<_CollapsiblePreferencesSections> createState() =>
      _CollapsiblePreferencesSectionsState();
}

class _CollapsiblePreferencesSectionsState
    extends State<_CollapsiblePreferencesSections> {
  String capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
  final Map<String, bool> _expanded = {
    'food': false,
    'outing': false,
    'interests': false,
    'location': false,
  };

  Widget buildChips(String key) {
    final items = widget.prefs[key] is List
        ? List<String>.from(widget.prefs[key])
        : <String>[];
    if (!_expanded[key]!) return const SizedBox.shrink();
    if (items.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Text(
            'No ${capitalize(key)} set.',
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
        ),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items
          .map(
            (item) => Chip(
              label: Text(item),
              backgroundColor: const Color(0xFFFFEAD0),
              side: const BorderSide(color: Color(0xFF96616B)),
              labelStyle: const TextStyle(
                color: Color(0xFF96616B),
                fontWeight: FontWeight.w500,
              ),
            ),
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection('food', 'Food'),
        _buildSection('outing', 'Outing'),
        _buildSection('interests', 'Interests'),
        _buildSection('location', 'Location'),
      ],
    );
  }

  Widget _buildSection(String key, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _expanded[key] = !_expanded[key]!;
            });
          },
          child: Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF96616B),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                _expanded[key]!
                    ? Icons.keyboard_arrow_down
                    : Icons.keyboard_arrow_right,
                size: 20,
                color: Colors.grey[700],
              ),
            ],
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(left: 24, top: 8, bottom: 16),
            child: buildChips(key),
          ),
          crossFadeState: _expanded[key]!
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }
}
