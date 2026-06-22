import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_asset_image.dart';
import 'course_data.dart';
import 'user_progress_controller.dart';

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
  int _attempts = 0;

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
              const SizedBox(height: 14),
              _GameStatsRow(
                activity: activity,
                section: section,
                attempts: _attempts,
              ),
              const SizedBox(height: 14),
              _LessonCard(language: language, section: section),
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
                  _playTapFeedback();
                  setState(() => _selectedOption = option);
                },
                onWordSelected: (word) {
                  _playTapFeedback();
                  setState(() => _selectedWords.add(word));
                },
                onWordRemoved: (word) {
                  _playTapFeedback();
                  setState(() => _selectedWords.remove(word));
                },
                onStreakConfirmed: () {
                  _playTapFeedback();
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

  Future<void> _checkAnswer() async {
    final correct = switch (activity.type) {
      ActivityType.writing =>
        _normalize(_answerController.text) == _normalize(activity.answer),
      ActivityType.multipleChoice => _selectedOption == activity.answer,
      ActivityType.streak => _streakConfirmed,
      ActivityType.sentenceOrder => _selectedWords.join(' ') == activity.answer,
      ActivityType.readingStory => _selectedOption == activity.answer,
      ActivityType.dialogue => _selectedOption == activity.answer,
      ActivityType.missingWord => _selectedOption == activity.answer,
    };

    setState(() {
      _isCorrect = correct;
      _attempts++;
    });

    _playResultFeedback(correct);

    final gainedExp = correct
        ? await UserProgressController.completeActivityAndSave(
            languageName: language.name,
            area: section.area,
            activityId: activity.id,
          )
        : false;

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          correct
              ? gainedExp
                    ? '${activity.successMessage} +$expPerActivity EXP'
                    : 'Actividad repasada. Tu EXP ya estaba registrada.'
              : 'Todavía no. Revisa la pista e intenta otra vez.',
        ),
      ),
    );

    if (correct) {
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) Navigator.pop(context, gainedExp);
      });
    }
  }

  String _normalize(String value) {
    return value.trim().toLowerCase();
  }

  void _playTapFeedback() {
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.selectionClick();
  }

  void _playResultFeedback(bool correct) {
    SystemSound.play(correct ? SystemSoundType.click : SystemSoundType.alert);
    if (correct) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }
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
          AppAssetImage(
            asset: section.imageAsset,
            fallbackIcon: section.icon,
            color: language.color,
            size: 54,
          ),
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

class _GameStatsRow extends StatelessWidget {
  final CourseActivity activity;
  final CourseSection section;
  final int attempts;

  const _GameStatsRow({
    required this.activity,
    required this.section,
    required this.attempts,
  });

  @override
  Widget build(BuildContext context) {
    final gameLabel = switch (activity.type) {
      ActivityType.writing => 'Reto de palabra',
      ActivityType.multipleChoice => 'Busca tesoro',
      ActivityType.streak => 'Fuego diario',
      ActivityType.sentenceOrder => 'Arma frase',
      ActivityType.readingStory => 'Cuento',
      ActivityType.dialogue => 'Dialogo',
      ActivityType.missingWord => 'Atrapa palabra',
    };
    final gameIcon = switch (activity.type) {
      ActivityType.writing => Icons.edit_rounded,
      ActivityType.multipleChoice => Icons.extension_rounded,
      ActivityType.streak => Icons.local_fire_department,
      ActivityType.sentenceOrder => Icons.sort_rounded,
      ActivityType.readingStory => Icons.auto_stories_rounded,
      ActivityType.dialogue => Icons.chat_bubble_outline_rounded,
      ActivityType.missingWord => Icons.my_location_rounded,
    };

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _GameChip(icon: gameIcon, label: gameLabel, color: section.color),
        const _GameChip(
          icon: Icons.bolt_rounded,
          label: '+$expPerActivity EXP',
          color: Color(0xFFFFE08A),
        ),
        _GameChip(
          icon: Icons.favorite_rounded,
          label: attempts == 0 ? '3 vidas' : '$attempts intento(s)',
          color: const Color(0xFFFFDDE4),
        ),
      ],
    );
  }
}

class _GameChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _GameChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18, color: const Color(0xFF134343)),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
      backgroundColor: color,
      side: BorderSide.none,
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
      ActivityType.readingStory => _ReadingStoryPractice(
        activity: activity,
        selectedOption: selectedOption,
        locked: locked,
        onSelected: onOptionSelected,
      ),
      ActivityType.dialogue => _DialoguePractice(
        activity: activity,
        selectedOption: selectedOption,
        locked: locked,
        onSelected: onOptionSelected,
      ),
      ActivityType.missingWord => _MissingWordPractice(
        activity: activity,
        selectedOption: selectedOption,
        locked: locked,
        onSelected: onOptionSelected,
      ),
    };

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _MiniMission(activity: activity),
          if (activity.readingText.isNotEmpty &&
              activity.type != ActivityType.readingStory &&
              activity.type != ActivityType.dialogue) ...[
            const SizedBox(height: 12),
            _ReadingContext(activity: activity),
          ],
          if (activity.helperText.isNotEmpty &&
              activity.type != ActivityType.readingStory &&
              activity.type != ActivityType.dialogue &&
              activity.type != ActivityType.missingWord) ...[
            const SizedBox(height: 12),
            _HelperNote(text: activity.helperText),
          ],
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final CourseLanguage language;
  final CourseSection section;

  const _LessonCard({required this.language, required this.section});

  @override
  Widget build(BuildContext context) {
    final lesson = _lessonFor(language.name, section.area);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF6F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: language.color.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.school_outlined, color: language.color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  lesson.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(lesson.body, style: const TextStyle(height: 1.3)),
          if (lesson.example.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                lesson.example,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static _LessonInfo _lessonFor(String languageName, SkillArea area) {
    final normalized = languageName.toLowerCase();
    final alphabet = normalized.contains('maya')
        ? "a, b, ch, e, i, j, k, k', l, m, n, o, p, t, ts, u, x, y"
        : normalized.contains('mixteco')
        ? 'a, ch, e, i, k, ku, n, nd, s, t, u, v, x, y'
        : normalized.contains('otom')
        ? 'a, e, h, i, m, n, o, p, r, t, u, x, y, z'
        : normalized.contains('pur')
        ? 'a, ch, e, i, j, k, m, n, p, r, s, t, ts, u, x'
        : 'a, ch, e, i, k, ku, l, m, n, o, p, s, t, tl, tz, x, y';

    return switch (area) {
      SkillArea.lectura => const _LessonInfo(
        title: 'Antes de leer',
        body:
            'Lee primero en el dialecto. Despues mira la traduccion y busca tres cosas: personaje, accion y lugar.',
        example: 'Pregunta guia: quien aparece?, que hace?, donde pasa?',
      ),
      SkillArea.escritura => _LessonInfo(
        title: 'Como escribir mejor',
        body:
            'Usa este abecedario de apoyo: $alphabet. Mira la palabra, dila en voz baja, separala en sonidos y escribela despacio.',
        example: 'Tecnica: mirar -> decir -> tapar -> escribir -> revisar.',
      ),
      SkillArea.gramatica => const _LessonInfo(
        title: 'Base de gramatica',
        body:
            'Para formar una frase, busca primero quien habla, despues la accion y al final la palabra clave. Compara con el espanol.',
        example: 'Modelo facil: Yo + aprendo + palabra.',
      ),
      SkillArea.racha => const _LessonInfo(
        title: 'Racha automatica',
        body:
            'La racha aumenta cuando completas actividades nuevas. No necesitas presionar un boton de asistencia.',
        example: 'Meta: completar lectura, escritura o gramatica del dialecto.',
      ),
    };
  }
}

class _LessonInfo {
  final String title;
  final String body;
  final String example;

  const _LessonInfo({
    required this.title,
    required this.body,
    required this.example,
  });
}

class _MiniMission extends StatelessWidget {
  final CourseActivity activity;

  const _MiniMission({required this.activity});

  @override
  Widget build(BuildContext context) {
    final mission = switch (activity.type) {
      ActivityType.writing => 'Escribe la palabra secreta',
      ActivityType.multipleChoice => 'Toca la respuesta escondida',
      ActivityType.streak => 'Enciende tu racha de hoy',
      ActivityType.sentenceOrder => 'Acomoda las piezas de la frase',
      ActivityType.readingStory => 'Lee el cuento y responde',
      ActivityType.dialogue => 'Lee la charla y contesta',
      ActivityType.missingWord => 'Atrapa la palabra que falta',
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6C5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: Color(0xFF134343)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              mission,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
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

class _ReadingStoryPractice extends StatelessWidget {
  final CourseActivity activity;
  final String? selectedOption;
  final bool locked;
  final ValueChanged<String> onSelected;

  const _ReadingStoryPractice({
    required this.activity,
    required this.selectedOption,
    required this.locked,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TextPanel(
          icon: Icons.auto_stories_rounded,
          title: 'Lectura en dialecto',
          text: activity.readingText,
        ),
        const SizedBox(height: 12),
        _TextPanel(
          icon: Icons.translate_rounded,
          title: 'Traduccion en espanol',
          text: activity.translationText,
        ),
        const SizedBox(height: 16),
        _HelperNote(text: activity.helperText),
        const SizedBox(height: 12),
        _OptionList(
          activity: activity,
          selectedOption: selectedOption,
          locked: locked,
          onSelected: onSelected,
        ),
      ],
    );
  }
}

class _DialoguePractice extends StatelessWidget {
  final CourseActivity activity;
  final String? selectedOption;
  final bool locked;
  final ValueChanged<String> onSelected;

  const _DialoguePractice({
    required this.activity,
    required this.selectedOption,
    required this.locked,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TextPanel(
          icon: Icons.forum_outlined,
          title: 'Dialogo',
          text: activity.readingText,
        ),
        const SizedBox(height: 12),
        _TextPanel(
          icon: Icons.translate_rounded,
          title: 'Significado',
          text: activity.translationText,
        ),
        const SizedBox(height: 16),
        _HelperNote(text: activity.helperText),
        const SizedBox(height: 12),
        _OptionList(
          activity: activity,
          selectedOption: selectedOption,
          locked: locked,
          onSelected: onSelected,
        ),
      ],
    );
  }
}

class _ReadingContext extends StatelessWidget {
  final CourseActivity activity;

  const _ReadingContext({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TextPanel(
          icon: Icons.auto_stories_rounded,
          title: 'Lectura en dialecto',
          text: activity.readingText,
        ),
        const SizedBox(height: 12),
        _TextPanel(
          icon: Icons.translate_rounded,
          title: 'Traduccion en espanol',
          text: activity.translationText,
        ),
      ],
    );
  }
}

class _MissingWordPractice extends StatelessWidget {
  final CourseActivity activity;
  final String? selectedOption;
  final bool locked;
  final ValueChanged<String> onSelected;

  const _MissingWordPractice({
    required this.activity,
    required this.selectedOption,
    required this.locked,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HelperNote(text: activity.helperText),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: activity.options.map((option) {
            final selected = option == selectedOption;
            return ChoiceChip(
              selected: selected,
              label: Text(option),
              onSelected: locked ? null : (_) => onSelected(option),
              selectedColor: const Color(0xFFFFE08A),
              backgroundColor: const Color(0xFFE7ECEF),
              labelStyle: TextStyle(
                fontWeight: FontWeight.w900,
                color: selected ? const Color(0xFF134343) : Colors.black87,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _TextPanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _TextPanel({
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8EC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF134343), size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 10),
          Text(text, style: const TextStyle(height: 1.35)),
        ],
      ),
    );
  }
}

class _HelperNote extends StatelessWidget {
  final String text;

  const _HelperNote({required this.text});

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF6F5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline, color: Color(0xFF134343)),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(height: 1.3))),
        ],
      ),
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
