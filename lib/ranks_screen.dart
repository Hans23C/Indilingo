import 'package:flutter/material.dart';

import 'course_data.dart';

class RanksScreen extends StatelessWidget {
  final List<CourseLanguage> languages;

  const RanksScreen({super.key, required this.languages});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Mis rangos')),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
          itemCount: languages.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final language = languages[index];
            return _RankCard(language: language);
          },
        ),
      ),
    );
  }
}

class _RankCard extends StatelessWidget {
  final CourseLanguage language;

  const _RankCard({required this.language});

  @override
  Widget build(BuildContext context) {
    final nextRank = _nextRank(language.exp);
    final progressToNext = nextRank == null
        ? 1.0
        : ((language.exp - language.rank.minExp) /
                  (nextRank.minExp - language.rank.minExp))
              .clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: language.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(language.icon, color: language.color, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${language.exp} EXP acumulada',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              Icon(language.rank.icon, color: language.color, size: 34),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            language.rank.name,
            style: TextStyle(
              color: language.color,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progressToNext,
              minHeight: 9,
              color: language.color,
              backgroundColor: language.color.withValues(alpha: 0.14),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            nextRank == null
                ? 'Rango máximo alcanzado'
                : '${nextRank.minExp - language.exp} EXP para ${nextRank.name}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatChip(
                icon: Icons.local_fire_department_outlined,
                label: '${language.streakDays} días de racha',
              ),
              _StatChip(
                icon: Icons.check_circle_outline,
                label: '${language.exp ~/ expPerActivity} actividades hechas',
              ),
            ],
          ),
        ],
      ),
    );
  }

  LanguageRank? _nextRank(int exp) {
    for (final rank in languageRanks) {
      if (rank.minExp > exp) return rank;
    }
    return null;
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      backgroundColor: const Color(0xFFFFF6C5),
    );
  }
}
