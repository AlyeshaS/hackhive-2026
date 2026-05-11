import 'package:flutter/material.dart';
import '../models/love_letter.dart';
import '../tabs/love_letter_detail.dart';

class LoveLetterTile extends StatelessWidget {
  final LoveLetter letter;
  final VoidCallback? onTap;

  const LoveLetterTile({required this.letter, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final cardColor = theme.cardTheme.color ?? cs.surface;
    return InkWell(
      onTap:
          onTap ??
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LoveLetterDetailPage(letter: letter),
            ),
          ),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  _formatDate(letter.createdAt),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              letter.text,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime dt) {
    // simple MM/DD or if older show yyyy
    final now = DateTime.now();
    if (dt.year == now.year) {
      return '${dt.month}/${dt.day}';
    }
    return '${dt.month}/${dt.day}/${dt.year}';
  }
}
