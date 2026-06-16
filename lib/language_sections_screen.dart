import 'package:flutter/material.dart';

import 'course_data.dart';
import 'language_path_screen.dart';

class LanguageSectionsScreen extends StatelessWidget {
  final CourseLanguage language;

  const LanguageSectionsScreen({super.key, required this.language});

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
                    Icon(
                      language.icon,
                      color: language.color.withValues(alpha: 0.20),
                      size: 120,
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
            ],
          ),
        ),
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
                child: Icon(section.icon, color: language.color, size: 34),
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
                '${section.exp} EXP',
                style: TextStyle(
                  color: language.color,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${section.activities.length} actividades',
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
