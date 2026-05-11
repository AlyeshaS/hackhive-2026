import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/love_letter_service.dart';
import '../widgets/love_letter_tile.dart';
import '../models/love_letter.dart';
import 'compose_love_letter.dart';

class LoveLettersTab extends StatefulWidget {
  const LoveLettersTab({super.key});

  @override
  State<LoveLettersTab> createState() => _LoveLettersTabState();
}

class _LoveLettersTabState extends State<LoveLettersTab> {
  bool _showSent = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
          child: StreamBuilder<List<LoveLetter>>(
            initialData: const <LoveLetter>[],
            stream: LoveLetterService().streamForCurrentUser(),
            builder: (context, snapshot) {
              final letters = snapshot.data ?? [];
              final user = FirebaseAuth.instance.currentUser;
              final uid = user?.uid ?? '';
              final received = letters
                  .where((l) => l.recipientId == uid)
                  .toList();
              final sent = letters.where((l) => l.senderId == uid).toList();
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              // Empty states for each tab
              if (!_showSent && received.isEmpty) {
                return _buildEmptyState(context, cs);
              }
              if (_showSent && sent.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.send_outlined,
                          size: 56,
                          color: cs.onSurfaceVariant,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No sent letters',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your sent letters will appear here.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final listToShow = _showSent ? sent : received;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _showSent = true),
                          child: _LegendChip(
                            icon: Icons.send_outlined,
                            label: 'Sent',
                            cs: cs,
                            active: _showSent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () => setState(() => _showSent = false),
                          child: _LegendChip(
                            icon: Icons.inbox_rounded,
                            label: 'Received',
                            cs: cs,
                            active: !_showSent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) {
                        final offsetAnim = Tween<Offset>(
                          begin: const Offset(0, 0.02),
                          end: Offset.zero,
                        ).animate(animation);
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: offsetAnim,
                            child: child,
                          ),
                        );
                      },
                      child: ListView.separated(
                        key: ValueKey<bool>(_showSent),
                        itemCount: listToShow.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, idx) {
                          final letter = listToShow[idx];
                          if (_showSent) {
                            return LoveLetterTile(
                              letter: letter,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ComposeLoveLetterPage(
                                    editingLetter: letter,
                                  ),
                                ),
                              ),
                            );
                          }
                          return LoveLetterTile(letter: letter);
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        Positioned(
          right: 20,
          bottom: 24,
          child: FloatingActionButton(
            backgroundColor: cs.primary,
            foregroundColor: cs.onPrimary,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ComposeLoveLetterPage()),
            ),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme cs) {
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
              child: Icon(
                Icons.mail_outline_rounded,
                size: 32,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Love Letters',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Send heartfelt letters and time-capsule messages to be opened in the future.',
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
                'Write one',
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

class _LegendChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme cs;
  final bool active;
  const _LegendChip({
    required this.icon,
    required this.label,
    required this.cs,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? cs.primaryContainer : cs.surfaceContainerHighest,
            border: Border.all(color: active ? cs.primary : cs.outlineVariant),
          ),
          child: Icon(
            icon,
            size: 18,
            color: active ? cs.primary : cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: active ? cs.onSurface : cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
