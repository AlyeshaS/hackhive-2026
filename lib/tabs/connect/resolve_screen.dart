import 'package:flutter/material.dart';

class ResolveScreen extends StatefulWidget {
  const ResolveScreen({super.key});

  @override
  State<ResolveScreen> createState() => _ResolveScreenState();
}

class _ResolveScreenState extends State<ResolveScreen> {
  int currentStage = 0;
  int currentPromptIndex = 0;
  bool hasStartedQuestions = false;
  String selectedMode = 'Miscommunication';
  final TextEditingController customModeController = TextEditingController();

  late List<String> sessionModes;
  int lastCustomIndex = -1;
  late PageController _introPageController;
  int _introPageIndex = 0;

  final Map<String, List<String>> responses = {
    'Private Reflection': [],
    'Shared Discussion': [],
    'Resolution': [],
  };

  final TextEditingController responseController = TextEditingController();

  static const List<String> modes = [
    'Miscommunication',
    'Jealousy',
    'Feeling disconnected',
    'Stress',
    'Boundaries',
    'Long-distance struggles',
  ];

  static const List<String> stageTitles = [
    'Private Reflection',
    'Shared Discussion',
    'Resolution',
  ];

  static const List<String> reflectionPrompts = [
    'What are you feeling right now?',
    'What part of the situation hurt you the most?',
    'What do you wish your partner understood?',
    'What do you need emotionally right now?',
    'Is there something you have not said yet because you were afraid to?',
    'What do you think your partner may be feeling?',
  ];

  static const List<String> sharedDiscussionPrompts = [
    'What did you learn from your partner’s response?',
    'What surprised you the most?',
    'What part of their response helped you understand them better?',
    'What do you think both of you need moving forward?',
  ];

  static const List<String> resolutionPrompts = [
    'What is one thing each of you can improve going forward?',
    'What reassurance would help rebuild connection?',
    'What small action could help both of you reconnect today?',
    'What can you both agree to work on together?',
  ];

  List<String> get currentPrompts {
    if (currentStage == 0) return reflectionPrompts;
    if (currentStage == 1) return sharedDiscussionPrompts;
    return resolutionPrompts;
  }

  String get currentStageTitle => stageTitles[currentStage];

  bool get isLastStage => currentStage == stageTitles.length - 1;
  bool get isLastPrompt => currentPromptIndex == currentPrompts.length - 1;

  void nextPrompt() {
    final text = responseController.text.trim();

    if (text.isNotEmpty) {
      responses[currentStageTitle]!.add(text);
    } else {
      responses[currentStageTitle]!.add('');
    }

    responseController.clear();

    if (!isLastPrompt) {
      setState(() {
        currentPromptIndex++;
      });
    } else if (!isLastStage) {
      setState(() {
        currentStage++;
        currentPromptIndex = 0;
      });
    } else {
      setState(() {
        currentStage = 3;
        currentPromptIndex = 0;
      });
    }
  }

  void goBack() {
    if (currentStage == 3) {
      setState(() {
        currentStage = 2;
        currentPromptIndex = resolutionPrompts.length - 1;
      });
      return;
    }

    if (currentPromptIndex > 0) {
      setState(() {
        currentPromptIndex--;
      });
    } else if (currentStage > 0) {
      setState(() {
        currentStage--;
        currentPromptIndex = currentPrompts.length - 1;
      });
    }
  }

  void restartSession() {
    setState(() {
      currentStage = 0;
      currentPromptIndex = 0;
      hasStartedQuestions = false;
      selectedMode = 'Miscommunication';
      sessionModes = List.from(modes);
      lastCustomIndex = -1;
      responseController.clear();
      responses.updateAll((key, value) => []);
    });
  }

  void startQuestions() {
    setState(() {
      hasStartedQuestions = true;
    });
  }

  Future<void> showCustomModeDialog() async {
    final isBuiltIn = modes.contains(selectedMode);
    customModeController.text = isBuiltIn ? '' : selectedMode;

    final customMode = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Custom situation'),
        content: TextField(
          controller: customModeController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'What are you working through?',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = customModeController.text.trim();
              Navigator.pop(dialogContext, value.isEmpty ? null : value);
            },
            child: const Text('Use it'),
          ),
        ],
      ),
    );

    if (customMode != null && customMode.isNotEmpty && mounted) {
      setState(() {
        final existingIndex = sessionModes.indexOf(customMode);

        if (existingIndex != -1) {
          selectedMode = customMode;
          if (existingIndex >= modes.length) {
            lastCustomIndex = existingIndex;
          }
        } else {
          final insertAt = lastCustomIndex >= 0
              ? lastCustomIndex + 1
              : modes.length;
          sessionModes.insert(insertAt, customMode);
          lastCustomIndex = insertAt;
          selectedMode = customMode;
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    sessionModes = List.from(modes);
    _introPageController = PageController();
  }

  @override
  void dispose() {
    responseController.dispose();
    customModeController.dispose();
    _introPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (currentStage == 3) {
      return _EndingScreen(onRestart: restartSession);
    }

    if (!hasStartedQuestions) {
      // Recreate controller with the desired initial page
      _introPageController = PageController(initialPage: _introPageIndex);

      return SizedBox(
        height: MediaQuery.of(context).size.height - 80,
        child: PageView(
          controller: _introPageController,
          physics: const PageScrollPhysics(),
          onPageChanged: (page) {
            setState(() {
              _introPageIndex = page;
            });
          },
          children: [
            // Landing intro centered with Get started
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: SizedBox(
                height: MediaQuery.of(context).size.height - 160,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _HeroCard(),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: () {
                          _introPageController.animateToPage(
                            1,
                            duration: const Duration(milliseconds: 420),
                            curve: Curves.easeOutCubic,
                          );
                        },
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          minimumSize: const Size(220, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text('Get started'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Mode selector page (swipe-to)
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ModeSelector(
                    modes: sessionModes,
                    selectedMode: selectedMode,
                    onChanged: (mode) {
                      setState(() {
                        selectedMode = mode;
                      });
                    },
                    onCustomPressed: showCustomModeDialog,
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: startQuestions,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text('Start Questions'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProgressHeader(
            stageTitle: currentStageTitle,
            currentPromptIndex: currentPromptIndex,
            totalPrompts: currentPrompts.length,
            progress: (currentPromptIndex + 1) / currentPrompts.length,
            selectedMode: selectedMode,
          ),
          const SizedBox(height: 16),
          _PromptCard(
            prompt: currentPrompts[currentPromptIndex],
            controller: responseController,
          ),
          const SizedBox(height: 20),
          _NavigationButtons(
            canGoBack: currentStage > 0 || currentPromptIndex > 0,
            isLastPrompt: isLastPrompt,
            isLastStage: isLastStage,
            onBack: goBack,
            onNext: nextPrompt,
            showIntroBack: currentStage == 0 && currentPromptIndex == 0,
            onIntroBack: () {
              _introPageIndex = 1;
              setState(() {
                hasStartedQuestions = false;
              });
            },
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [cs.primaryContainer, cs.secondaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: cs.primary.withOpacity(0.16)),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF231519) : Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LabelPill(text: 'Resolve'),
            const SizedBox(height: 16),
            Text(
              'Healthy relationships are not built on avoiding conflict, but on learning how to navigate it together.',
              style: textTheme.titleMedium?.copyWith(
                height: 1.45,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'This space helps both of you slow down, reflect, and communicate with intention. The goal is not to win the conversation, but to understand each other and move forward together.',
              style: textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Take your time. Be honest. Be kind. Remember that you are on the same team.',
              style: textTheme.bodyMedium?.copyWith(
                color: cs.onSurface,
                height: 1.55,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeSelector extends StatelessWidget {
  final List<String> modes;
  final String selectedMode;
  final ValueChanged<String> onChanged;
  final VoidCallback onCustomPressed;

  const _ModeSelector({
    required this.modes,
    required this.selectedMode,
    required this.onChanged,
    required this.onCustomPressed,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What are you working through?',
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose a situation so the session feels more focused.',
          style: textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ...modes.map((mode) {
              final selected = selectedMode == mode;

              return ChoiceChip(
                label: Text(mode),
                selected: selected,
                onSelected: (_) => onChanged(mode),
                selectedColor: cs.primaryContainer,
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                labelStyle: TextStyle(
                  color: selected ? cs.onPrimaryContainer : cs.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                  side: BorderSide(
                    color: selected
                        ? cs.primary.withOpacity(0.35)
                        : cs.outlineVariant,
                    width: 1.0,
                  ),
                ),
              );
            }),
            ActionChip(
              avatar: const Icon(Icons.add, size: 18),
              label: const Text('Custom'),
              onPressed: onCustomPressed,
              backgroundColor: cs.surfaceContainerHighest,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              labelStyle: TextStyle(
                color: cs.onSurface,
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
                side: BorderSide(color: cs.outlineVariant, width: 1.0),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  final String stageTitle;
  final int currentPromptIndex;
  final int totalPrompts;
  final double progress;
  final String selectedMode;

  const _ProgressHeader({
    required this.stageTitle,
    required this.currentPromptIndex,
    required this.totalPrompts,
    required this.progress,
    required this.selectedMode,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withOpacity(0.7),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Working through: $selectedMode',
              style: textTheme.labelMedium?.copyWith(
                color: cs.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            stageTitle,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Question ${currentPromptIndex + 1} of $totalPrompts',
            style: textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            borderRadius: BorderRadius.circular(999),
            backgroundColor: cs.surfaceContainerHighest,
            color: cs.primary,
          ),
        ],
      ),
    );
  }
}

class _PromptCard extends StatelessWidget {
  final String prompt;
  final TextEditingController controller;

  const _PromptCard({required this.prompt, required this.controller});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Calculate responsive line counts based on device height
    final screenHeight = MediaQuery.of(context).size.height;
    late int minLines;
    late int maxLines;

    if (screenHeight > 900) {
      minLines = 10;
      maxLines = 14;
    } else if (screenHeight > 800) {
      minLines = 8;
      maxLines = 11;
    } else if (screenHeight > 700) {
      minLines = 7;
      maxLines = 9;
    } else {
      minLines = 5;
      maxLines = 7;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SoftMessage(text: 'Read to understand, not to respond.'),
          const SizedBox(height: 18),
          Text(
            prompt,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: controller,
            minLines: minLines,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: 'Write your thoughts here...',
              filled: true,
              fillColor: cs.surfaceContainerHighest.withOpacity(0.45),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: cs.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: cs.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: cs.primary, width: 1.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigationButtons extends StatelessWidget {
  final bool canGoBack;
  final bool isLastPrompt;
  final bool isLastStage;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final bool showIntroBack;
  final VoidCallback? onIntroBack;

  const _NavigationButtons({
    required this.canGoBack,
    required this.isLastPrompt,
    required this.isLastStage,
    required this.onBack,
    required this.onNext,
    this.showIntroBack = false,
    this.onIntroBack,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    String buttonText = 'Next';

    if (isLastPrompt && !isLastStage) {
      buttonText = 'Continue';
    } else if (isLastPrompt && isLastStage) {
      buttonText = 'Finish session';
    }

    return Row(
      children: [
        if (canGoBack || showIntroBack)
          Expanded(
            child: OutlinedButton(
              onPressed: canGoBack ? onBack : onIntroBack,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                side: BorderSide(color: cs.outline),
              ),
              child: const Text('Back'),
            ),
          ),
        if (canGoBack || showIntroBack) const SizedBox(width: 12),
        Expanded(
          child: FilledButton(
            onPressed: onNext,
            style: FilledButton.styleFrom(
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: Text(buttonText),
          ),
        ),
      ],
    );
  }
}

class _EndingScreen extends StatelessWidget {
  final VoidCallback onRestart;

  const _EndingScreen({required this.onRestart});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: cs.primary.withOpacity(0.16)),
              boxShadow: [
                BoxShadow(
                  color: cs.primary.withOpacity(0.10),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LabelPill(text: 'Session complete'),
                const SizedBox(height: 18),
                Text(
                  'Thank you for taking the time to listen to each other.',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Communication is not always easy, but choosing to understand one another is an important act of care and connection.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 18),
                _SoftMessage(
                  text:
                      'Your relationship character feels proud of you both for trying.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: onRestart,
            style: FilledButton.styleFrom(
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: const Text('Start another session'),
          ),
        ],
      ),
    );
  }
}

class _LabelPill extends StatelessWidget {
  final String text;

  const _LabelPill({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: textTheme.labelLarge?.copyWith(
          color: cs.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SoftMessage extends StatelessWidget {
  final String text;

  const _SoftMessage({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withOpacity(0.45),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        style: textTheme.bodySmall?.copyWith(
          color: cs.onPrimaryContainer,
          height: 1.45,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
