import 'package:flutter/material.dart';

import 'course_data.dart';

class ActivityScreen extends StatefulWidget {
  final CourseLanguage language;
  final CourseSection section;
  final CourseActivity activity;

  const ActivityScreen({
    super.key,
    required this.language,
    required this.section,
    required this.activity,
  });

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final TextEditingController _answerController = TextEditingController();
  final List<String> _selectedWords = [];
  String? _selectedOption;
  bool _streakConfirmed = false;
  bool _isCorrect = false;

  CourseActivity get activity => widget.activity;
  CourseLanguage get language => widget.language;
  CourseSection get section => widget.section;
  bool get locked => activity.status == ActivityStatus.locked;

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(section.title)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ActivityHeader(
                language: language,
                section: section,
                activity: activity,
              ),
              const SizedBox(height: 22),
              Text(
                locked ? 'Actividad bloqueada' : activity.instruction,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF134343),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                locked
                    ? 'Completa las actividades anteriores para desbloquear esta práctica.'
                    : activity.prompt,
                style: const TextStyle(fontSize: 16, height: 1.35),
              ),
              const SizedBox(height: 24),
              _PracticeBox(
                activity: activity,
                locked: locked,
                answerController: _answerController,
                selectedOption: _selectedOption,
                selectedWords: _selectedWords,
                streakConfirmed: _streakConfirmed,
                onOptionSelected: (option) {
                  setState(() => _selectedOption = option);
                },
                onWordSelected: (word) {
                  setState(() => _selectedWords.add(word));
                },
                onWordRemoved: (word) {
                  setState(() => _selectedWords.remove(word));
                },
                onStreakConfirmed: () {
                  setState(() => _streakConfirmed = true);
                },
              ),
              if (_isCorrect) ...[
                const SizedBox(height: 16),
                _SuccessMessage(message: activity.successMessage),
              ],
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: locked ? null : _checkAnswer,
                  icon: Icon(
                    locked ? Icons.lock_outline : Icons.check_circle_outline,
                  ),
                  label: Text(locked ? 'Bloqueada' : 'Revisar actividad'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: language.color,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    disabledForegroundColor: Colors.grey.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _checkAnswer() {
    final correct = switch (activity.type) {
      ActivityType.writing =>
        _normalize(_answerController.text) == _normalize(activity.answer),
      ActivityType.multipleChoice => _selectedOption == activity.answer,
      ActivityType.streak => _streakConfirmed,
      ActivityType.sentenceOrder => _selectedWords.join(' ') == activity.answer,
    };

    setState(() => _isCorrect = correct);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          correct
              ? activity.successMessage
              : 'Todavía no. Revisa la pista e intenta otra vez.',
        ),
      ),
    );

    if (correct) {
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) Navigator.pop(context);
      });
    }
  }

  String _normalize(String value) {
    return value.trim().toLowerCase();
  }
}

class _ActivityHeader extends StatelessWidget {
  final CourseLanguage language;
  final CourseSection section;
  final CourseActivity activity;

  const _ActivityHeader({
    required this.language,
    required this.section,
    required this.activity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: section.color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(section.icon, color: language.color, size: 38),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text('${language.name} · ${section.title}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PracticeBox extends StatelessWidget {
  final CourseActivity activity;
  final bool locked;
  final TextEditingController answerController;
  final String? selectedOption;
  final List<String> selectedWords;
  final bool streakConfirmed;
  final ValueChanged<String> onOptionSelected;
  final ValueChanged<String> onWordSelected;
  final ValueChanged<String> onWordRemoved;
  final VoidCallback onStreakConfirmed;

  const _PracticeBox({
    required this.activity,
    required this.locked,
    required this.answerController,
    required this.selectedOption,
    required this.selectedWords,
    required this.streakConfirmed,
    required this.onOptionSelected,
    required this.onWordSelected,
    required this.onWordRemoved,
    required this.onStreakConfirmed,
  });

  @override
  Widget build(BuildContext context) {
    final child = switch (activity.type) {
      ActivityType.writing => TextField(
        controller: answerController,
        enabled: !locked,
        minLines: 4,
        maxLines: 6,
        decoration: InputDecoration(
          hintText: 'Escribe tu respuesta',
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      ActivityType.multipleChoice => _OptionList(
        activity: activity,
        selectedOption: selectedOption,
        locked: locked,
        onSelected: onOptionSelected,
      ),
      ActivityType.streak => _StreakPractice(
        activity: activity,
        locked: locked,
        confirmed: streakConfirmed,
        onConfirmed: onStreakConfirmed,
      ),
      ActivityType.sentenceOrder => _SentenceOrderPractice(
        activity: activity,
        locked: locked,
        selectedWords: selectedWords,
        onWordSelected: onWordSelected,
        onWordRemoved: onWordRemoved,
      ),
    };

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: child,
    );
  }
}

class _OptionList extends StatelessWidget {
  final CourseActivity activity;
  final String? selectedOption;
  final bool locked;
  final ValueChanged<String> onSelected;

  const _OptionList({
    required this.activity,
    required this.selectedOption,
    required this.locked,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: activity.options.map((option) {
        final selected = option == selectedOption;
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 10),
          child: OutlinedButton(
            onPressed: locked ? null : () => onSelected(option),
            style: OutlinedButton.styleFrom(
              backgroundColor: selected ? const Color(0xFFD1E9E9) : null,
              side: BorderSide(
                color: selected ? const Color(0xFF134343) : Colors.black26,
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(option),
          ),
        );
      }).toList(),
    );
  }
}

class _StreakPractice extends StatelessWidget {
  final CourseActivity activity;
  final bool locked;
  final bool confirmed;
  final VoidCallback onConfirmed;

  const _StreakPractice({
    required this.activity,
    required this.locked,
    required this.confirmed,
    required this.onConfirmed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          confirmed ? Icons.local_fire_department : Icons.today_outlined,
          size: 70,
          color: locked ? Colors.grey : const Color(0xFF134343),
        ),
        const SizedBox(height: 10),
        Text(
          locked ? 'Racha bloqueada' : 'Confirma tu ingreso de hoy',
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: locked ? null : onConfirmed,
          icon: Icon(confirmed ? Icons.check : Icons.bolt_outlined),
          label: Text(confirmed ? 'Día registrado' : 'Registrar racha'),
        ),
      ],
    );
  }
}

class _SentenceOrderPractice extends StatelessWidget {
  final CourseActivity activity;
  final bool locked;
  final List<String> selectedWords;
  final ValueChanged<String> onWordSelected;
  final ValueChanged<String> onWordRemoved;

  const _SentenceOrderPractice({
    required this.activity,
    required this.locked,
    required this.selectedWords,
    required this.onWordSelected,
    required this.onWordRemoved,
  });

  @override
  Widget build(BuildContext context) {
    final availableWords = activity.options
        .where((word) => !selectedWords.contains(word))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: selectedWords.isEmpty
              ? [
                  Chip(
                    label: Text(
                      locked ? 'Frase bloqueada' : 'Toca las palabras abajo',
                    ),
                  ),
                ]
              : selectedWords.map((word) {
                  return ActionChip(
                    label: Text(word),
                    onPressed: locked ? null : () => onWordRemoved(word),
                    backgroundColor: const Color(0xFFFFF6C5),
                  );
                }).toList(),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: availableWords.map((word) {
            return ActionChip(
              label: Text(word),
              onPressed: locked ? null : () => onWordSelected(word),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _SuccessMessage extends StatelessWidget {
  final String message;

  const _SuccessMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F4DD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF2E7D32)),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}
