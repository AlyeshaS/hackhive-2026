import 'package:flutter/material.dart';
import '../suggestions/suggestions_screen.dart';

class MemoriesScreen extends StatefulWidget {
  const MemoriesScreen({super.key});

  @override
  State<MemoriesScreen> createState() => _MemoriesScreenState();
}

class _MemoriesScreenState extends State<MemoriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
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
      appBar: AppBar(
        title: const Text('Memories'),
        bottom: TabBar(
          controller: _tabController,
          dividerColor: cs.outlineVariant,
          indicatorColor: cs.primary,
          indicatorWeight: 2,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'Timeline'),
            Tab(text: 'Milestones'),
            Tab(text: 'Watch'),
            Tab(text: 'Scrapbook'),
            Tab(text: 'Date Ideas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const _TimelineTab(),
          _ComingSoonTab(
            icon: Icons.emoji_events_outlined,
            title: 'Milestones & Achievements',
            subtitle:
                'Track your relationship streaks, milestones, and meaningful moments together.',
            cs: cs,
          ),
          _ComingSoonTab(
            icon: Icons.movie_outlined,
            title: 'Watch Together',
            subtitle:
                'A shared list of movies and shows, with reflective prompts after you watch.',
            cs: cs,
          ),
          _ComingSoonTab(
            icon: Icons.photo_album_outlined,
            title: 'Scrapbook',
            subtitle:
                'A beautiful space for photos, notes, and snapshots of your relationship.',
            cs: cs,
          ),
          // Date Ideas — wrap SuggestionsScreen in a MediaQuery override
          // to suppress its own AppBar/header since we already have the tab bar
          const _DateIdeasTab(),
        ],
      ),
    );
  }
}

// ── Date Ideas tab — wraps SuggestionsScreen cleanly ─────────────────────────

class _DateIdeasTab extends StatelessWidget {
  const _DateIdeasTab();

  @override
  Widget build(BuildContext context) {
    // SuggestionsScreen manages its own Scaffold/AppBar internally.
    // We render it inside a ClipRect so it fills the tab body without
    // showing its own screen title (it uses an AppBar with no title text
    // currently, so this is fine). If SuggestionsScreen ever adds its own
    // title AppBar, wrap it in a NestedScrollView or pass a `hideAppBar`
    // parameter instead.
    return const SuggestionsScreen();
  }
}

// ── Timeline Tab ──────────────────────────────────────────────────────────────

class _TimelineTab extends StatelessWidget {
  const _TimelineTab();

  static final List<Map<String, dynamic>> _events = [
    {
      'date': 'May 2 · 2 days ago',
      'title': 'Pottery class',
      'sub': 'Added 3 photos · Creative date',
      'emoji': '🎨',
      'milestone': false,
    },
    {
      'date': 'Apr 28 · Last week',
      'title': '6-month anniversary ✨',
      'sub': 'Milestone unlocked!',
      'emoji': '🎉',
      'milestone': true,
    },
    {
      'date': 'Apr 20',
      'title': 'Midnight picnic',
      'sub': 'Deep Talk · 8 topics explored',
      'emoji': '🌙',
      'milestone': false,
    },
    {
      'date': 'Apr 12',
      'title': 'Movie marathon',
      'sub': 'Watched 3 films together',
      'emoji': '🎬',
      'milestone': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YOUR STORY',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 16),
          ...List.generate(_events.length, (i) {
            final event = _events[i];
            final isMilestone = event['milestone'] as bool;
            final isLast = i == _events.length - 1;
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 32,
                    child: Column(
                      children: [
                        Container(
                          width: isMilestone ? 16 : 12,
                          height: isMilestone ? 16 : 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isMilestone
                                ? cs.primary
                                : cs.primaryContainer,
                            border: isMilestone
                                ? null
                                : Border.all(color: cs.primary, width: 1.5),
                          ),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 1.5,
                              color: cs.primary.withOpacity(0.2),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isMilestone
                              ? cs.primaryContainer
                              : (isDark
                                  ? const Color(0xFF231519)
                                  : Colors.white),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isMilestone
                                ? cs.primary.withOpacity(0.3)
                                : cs.outlineVariant,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              event['emoji'],
                              style: const TextStyle(fontSize: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event['date'],
                                    style:
                                        Theme.of(context).textTheme.labelSmall,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    event['title'],
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    event['sub'],
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: cs.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Full activity timeline coming soon',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant.withOpacity(0.6),
                    fontSize: 12,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared Coming Soon widget ─────────────────────────────────────────────────

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
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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