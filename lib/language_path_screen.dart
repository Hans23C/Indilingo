import 'package:flutter/material.dart';

import 'app_asset_image.dart';
import 'activity_screen.dart';
import 'course_data.dart';
import 'user_progress_controller.dart';

class LanguagePathScreen extends StatelessWidget {
  final CourseLanguage language;
  final CourseSection section;

  const LanguagePathScreen({
    super.key,
    required this.language,
    required this.section,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: UserProgressController.changes,
      builder: (context, _, __) {
        final currentLanguage = buildCourses().firstWhere(
          (item) => item.name == language.name,
          orElse: () => language,
        );
        final currentSection = currentLanguage.sections.firstWhere(
          (item) => item.area == section.area,
          orElse: () => section,
        );

        return _LanguagePathView(
          language: currentLanguage,
          section: currentSection,
        );
      },
    );
  }
}

class _LanguagePathView extends StatelessWidget {
  final CourseLanguage language;
  final CourseSection section;

  const _LanguagePathView({required this.language, required this.section});

  static const double _pathAspectRatio = 1060 / 4200;

  @override
  Widget build(BuildContext context) {
    if (section.area == SkillArea.racha) {
      return _StreakVisualScreen(language: language, section: section);
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text('${language.name} · ${section.title}')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: _ProgressHeader(language: language, section: section),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                child: AspectRatio(
                  aspectRatio: _pathAspectRatio,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final nodeSize = (constraints.maxWidth * 0.15).clamp(
                        50.0,
                        72.0,
                      );
                      return Stack(
                        children: [
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: Image.asset(
                                'assets/images/camino_niveles.png',
                                fit: BoxFit.fill,
                                errorBuilder: (_, __, ___) =>
                                    Container(color: const Color(0xFFEFE0C6)),
                              ),
                            ),
                          ),
                          ...List.generate(section.activities.length, (index) {
                            final activity = section.activities[index];
                            final position = _nodePosition(index);
                            return Positioned(
                              left:
                                  position.dx * constraints.maxWidth -
                                  nodeSize / 2,
                              top:
                                  position.dy * constraints.maxHeight -
                                  nodeSize / 2,
                              child: _ActivityNode(
                                language: language,
                                section: section,
                                activity: activity,
                                size: nodeSize,
                                onTap: () => _openActivity(context, activity),
                              ),
                            );
                          }),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openActivity(BuildContext context, CourseActivity activity) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ActivityScreen(
          language: language,
          section: section,
          activity: activity,
        ),
      ),
    );
  }

  static Offset _nodePosition(int index) {
    const columns = [0.20, 0.50, 0.78, 0.36, 0.64];
    final y = 0.035 + index * (0.93 / (maxActivitiesPerSection - 1));
    return Offset(columns[index % columns.length], y);
  }
}

class _StreakVisualScreen extends StatelessWidget {
  final CourseLanguage language;
  final CourseSection section;

  const _StreakVisualScreen({required this.language, required this.section});

  @override
  Widget build(BuildContext context) {
    final completedActivities = language.exp ~/ expPerActivity;
    final progressValue = (completedActivities / (maxActivitiesPerSection * 3))
        .clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text('${language.name} · ${section.title}')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: section.color,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  AppAssetImage(
                    asset: section.imageAsset,
                    fallbackIcon: section.icon,
                    color: language.color,
                    size: 112,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${language.streakDays}',
                    style: TextStyle(
                      color: language.color,
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Text(
                    'actividades que alimentan tu racha',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: progressValue,
                      minHeight: 12,
                      color: language.color,
                      backgroundColor: Colors.white.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const _StreakInfoTile(
              icon: Icons.auto_awesome_outlined,
              title: 'Se actualiza automaticamente',
              text:
                  'La racha sube cuando completas actividades nuevas de lectura, escritura, gramatica o repaso en cualquier dialecto.',
            ),
            _StreakInfoTile(
              icon: Icons.bolt_outlined,
              title: '$completedActivities actividades completadas',
              text:
                  'Cada actividad nueva suma EXP y tambien cuenta para tu constancia.',
            ),
            _StreakInfoTile(
              icon: language.rank.icon,
              title: language.rank.name,
              text: '${language.exp} EXP acumulada en ${language.name}.',
            ),
          ],
        ),
      ),
    );
  }
}

class _StreakInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _StreakInfoTile({
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF134343), size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(text, style: const TextStyle(height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  final CourseLanguage language;
  final CourseSection section;

  const _ProgressHeader({required this.language, required this.section});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: section.color,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: AppAssetImage(
                asset: section.imageAsset,
                fallbackIcon: section.icon,
                color: language.color,
                size: 40,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  '${section.exp} EXP acumulada en este apartado',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${section.activities.length}',
            style: TextStyle(
              color: language.color,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 4),
          const Text('act.'),
        ],
      ),
    );
  }
}

class _ActivityNode extends StatelessWidget {
  final CourseLanguage language;
  final CourseSection section;
  final CourseActivity activity;
  final double size;
  final VoidCallback onTap;

  const _ActivityNode({
    required this.language,
    required this.section,
    required this.activity,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = switch (activity.status) {
      ActivityStatus.completed => const Color(0xFFF5A623),
      ActivityStatus.active => language.color,
      ActivityStatus.available => const Color(0xFFFFD54F),
      ActivityStatus.locked => const Color(0xFF9E9E9E),
    };
    final icon = switch (activity.status) {
      ActivityStatus.completed => Icons.check_rounded,
      ActivityStatus.active => section.icon,
      ActivityStatus.available => Icons.play_arrow_rounded,
      ActivityStatus.locked => Icons.lock_outline,
    };

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.42),
                  blurRadius: activity.status == ActivityStatus.active ? 20 : 8,
                  spreadRadius: activity.status == ActivityStatus.active
                      ? 4
                      : 0,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: size * 0.46),
          ),
          const SizedBox(height: 4),
          Container(
            width: size + 28,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              activity.title.replaceFirst(RegExp(r'^\d+\.\s'), ''),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: (size * 0.16).clamp(9.0, 11.0),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
