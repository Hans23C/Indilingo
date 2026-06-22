import 'package:flutter/material.dart';

import 'app_asset_image.dart';
import 'course_data.dart';
import 'language_path_screen.dart';
import 'user_progress_controller.dart';

class LanguageSectionsScreen extends StatelessWidget {
  final CourseLanguage language;

  const LanguageSectionsScreen({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: UserProgressController.changes,
      builder: (context, _, __) {
        final currentLanguage = buildCourses().firstWhere(
          (item) => item.name == language.name,
          orElse: () => language,
        );

        return _LanguageSectionsView(language: currentLanguage);
      },
    );
  }
}

class _LanguageSectionsView extends StatelessWidget {
  final CourseLanguage language;

  const _LanguageSectionsView({required this.language});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(language.name),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Image.asset(
              'assets/images/logo.jpeg',
              width: 42,
              errorBuilder: (_, __, ___) => const Icon(Icons.language),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                language.greeting,
                style: const TextStyle(fontSize: 18, height: 1.25),
              ),
              const SizedBox(height: 20),
              Container(
                height: 190,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: language.color.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Opacity(
                      opacity: 0.22,
                      child: AppAssetImage(
                        asset: language.imageAsset,
                        fallbackIcon: language.icon,
                        color: language.color,
                        size: 170,
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          language.name,
                          style: TextStyle(
                            color: language.color,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${language.exp} EXP · ${language.rank.name}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${language.streakDays} días de racha',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Apartados',
                style: TextStyle(
                  color: Color(0xFF134343),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: language.sections.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.92,
                ),
                itemBuilder: (context, index) {
                  final section = language.sections[index];
                  return _SectionCard(
                    section: section,
                    language: language,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LanguagePathScreen(
                          language: language,
                          section: section,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Guias de aprendizaje',
                style: TextStyle(
                  color: Color(0xFF134343),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              ...language.sections.map((section) {
                return _LearningGuide(section: section, language: language);
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _LearningGuide extends StatelessWidget {
  final CourseLanguage language;
  final CourseSection section;

  const _LearningGuide({required this.language, required this.section});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppAssetImage(
                asset: section.imageAsset,
                fallbackIcon: section.icon,
                color: language.color,
                size: 30,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  section.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...section.learningTips.map((tip) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  Expanded(
                    child: Text(tip, style: const TextStyle(height: 1.25)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final CourseLanguage language;
  final CourseSection section;
  final VoidCallback onTap;

  const _SectionCard({
    required this.language,
    required this.section,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: section.color,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: AppAssetImage(
                  asset: section.imageAsset,
                  fallbackIcon: section.icon,
                  color: language.color,
                  size: 54,
                ),
              ),
              const Spacer(),
              Text(
                section.nativeTitle,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                section.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                section.area == SkillArea.racha
                    ? 'Vista de racha'
                    : '${section.exp} EXP',
                style: TextStyle(
                  color: language.color,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                section.area == SkillArea.racha
                    ? '${language.streakDays} avances registrados'
                    : '${section.activities.length} actividades',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
