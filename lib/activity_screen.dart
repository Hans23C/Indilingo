import 'package:flutter/material.dart';

import 'course_data.dart';

class ActivityScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final locked = activity.status == ActivityStatus.locked;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF134343),
        title: Text(section.title),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
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
                section: section,
                activity: activity,
                locked: locked,
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: locked
                      ? null
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Actividad completada en modo práctica.',
                              ),
                            ),
                          );
                          Navigator.pop(context);
                        },
                  icon: Icon(
                    locked ? Icons.lock_outline : Icons.check_circle_outline,
                  ),
                  label: Text(locked ? 'Bloqueada' : 'Marcar como completada'),
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
}

class _PracticeBox extends StatelessWidget {
  final CourseSection section;
  final CourseActivity activity;
  final bool locked;

  const _PracticeBox({
    required this.section,
    required this.activity,
    required this.locked,
  });

  @override
  Widget build(BuildContext context) {
    final child = switch (section.area) {
      SkillArea.escritura => TextField(
        enabled: !locked,
        minLines: 4,
        maxLines: 6,
        decoration: InputDecoration(
          hintText: 'Escribe aquí: ${activity.answer}',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      SkillArea.lectura => _OptionList(answer: activity.answer, locked: locked),
      SkillArea.hablado => Column(
        children: [
          Icon(
            Icons.mic_none,
            size: 70,
            color: locked ? Colors.grey : const Color(0xFF134343),
          ),
          const SizedBox(height: 10),
          Text(
            locked
                ? 'Micrófono bloqueado'
                : 'Pulsa mentalmente grabar y repite: ${activity.answer}',
            textAlign: TextAlign.center,
          ),
        ],
      ),
      SkillArea.gramatica => _GrammarTiles(
        answer: activity.answer,
        locked: locked,
      ),
    };

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: child,
    );
  }
}

class _OptionList extends StatelessWidget {
  final String answer;
  final bool locked;

  const _OptionList({required this.answer, required this.locked});

  @override
  Widget build(BuildContext context) {
    final options = [answer, 'saludo', 'camino', 'comunidad'];

    return Column(
      children: options.map((option) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 10),
          child: OutlinedButton(
            onPressed: locked ? null : () {},
            child: Text(option),
          ),
        );
      }).toList(),
    );
  }
}

class _GrammarTiles extends StatelessWidget {
  final String answer;
  final bool locked;

  const _GrammarTiles({required this.answer, required this.locked});

  @override
  Widget build(BuildContext context) {
    final parts = ['Yo', 'aprendo', answer];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: parts.map((part) {
        return Chip(
          label: Text(part),
          backgroundColor: locked
              ? Colors.grey.shade200
              : const Color(0xFFFFF6C5),
        );
      }).toList(),
    );
  }
}
