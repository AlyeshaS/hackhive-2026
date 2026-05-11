// connect_screen.dart
import 'package:flutter/material.dart';
import '../deep_talk/deep_talk_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../love_letters_tab.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Material(
                color: Colors.transparent,
                child: TabBar(
                  controller: _tabController,
                  dividerColor: cs.outlineVariant,
                  indicatorColor: cs.primary,
                  indicatorWeight: 2,
                  tabs: const [
                    Tab(text: 'Deep Talk'),
                    Tab(text: 'Letters'),
                    Tab(text: 'Conflict'),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                const DeepTalkScreen(),
                const LoveLettersTab(),
                _ComingSoonTab(
                  icon: Icons.handshake_outlined,
                  title: 'Conflict Mode',
                  subtitle:
                      'A guided space to navigate difficult conversations with care and structure.',
                  cs: cs,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ComingSoonTab extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final ColorScheme cs;
  const _ComingSoonTab({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.primaryContainer,
              ),
              child: Icon(icon, size: 32, color: cs.primary),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                'Coming soon',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: cs.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
