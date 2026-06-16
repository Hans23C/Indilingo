import 'package:flutter/material.dart';

enum SkillArea { escritura, lectura, racha, gramatica }

enum ActivityStatus { completed, active, available, locked }

enum ActivityType { writing, multipleChoice, streak, sentenceOrder }

class LanguageRank {
  final String name;
  final int minExp;
  final IconData icon;

  const LanguageRank({
    required this.name,
    required this.minExp,
    required this.icon,
  });
}

class CourseLanguage {
  final String name;
  final Color color;
  final IconData icon;
  final int exp;
  final int streakDays;
  final LanguageRank rank;
  final Offset mapFocus;
  final String greeting;
  final List<CourseSection> sections;

  const CourseLanguage({
    required this.name,
    required this.color,
    required this.icon,
    required this.exp,
    required this.streakDays,
    required this.rank,
    required this.mapFocus,
    required this.greeting,
    required this.sections,
  });
}

class CourseSection {
  final SkillArea area;
  final String title;
  final String nativeTitle;
  final String subtitle;
  final IconData icon;
  final Color color;
  final int exp;
  final List<CourseActivity> activities;

  const CourseSection({
    required this.area,
    required this.title,
    required this.nativeTitle,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.exp,
    required this.activities,
  });
}

class CourseActivity {
  final String id;
  final String title;
  final ActivityType type;
  final String instruction;
  final String prompt;
  final String answer;
  final List<String> options;
  final String successMessage;
  final ActivityStatus status;

  const CourseActivity({
    required this.id,
    required this.title,
    required this.type,
    required this.instruction,
    required this.prompt,
    required this.answer,
    required this.options,
    required this.successMessage,
    required this.status,
  });

  CourseActivity copyWith({String? title, ActivityStatus? status}) {
    return CourseActivity(
      id: id,
      title: title ?? this.title,
      type: type,
      instruction: instruction,
      prompt: prompt,
      answer: answer,
      options: options,
      successMessage: successMessage,
      status: status ?? this.status,
    );
  }
}

const int expPerActivity = 10;
const int maxActivitiesPerSection = 50;

const List<LanguageRank> languageRanks = [
  LanguageRank(name: 'Sembrador', minExp: 0, icon: Icons.eco_outlined),
  LanguageRank(name: 'Maestro Colibrí', minExp: 300, icon: Icons.auto_awesome),
  LanguageRank(
    name: 'Guerrero de la Comunidad',
    minExp: 700,
    icon: Icons.shield_outlined,
  ),
  LanguageRank(
    name: 'Guardián de la Palabra',
    minExp: 1200,
    icon: Icons.menu_book_outlined,
  ),
  LanguageRank(name: 'Maestro del Sol', minExp: 1700, icon: Icons.wb_sunny),
];

LanguageRank rankForExp(int exp) {
  return languageRanks.lastWhere((rank) => exp >= rank.minExp);
}
