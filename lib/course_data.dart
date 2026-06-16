import 'package:flutter/material.dart';

import 'activity_api.dart';
export 'course_models.dart';
import 'course_models.dart';

List<CourseLanguage> buildCourses() {
  return [
    _language(
      name: 'Náhuatl',
      color: const Color(0xFF1A948E),
      icon: Icons.waves,
      completedPerSection: 18,
      streakDays: 12,
      mapFocus: const Offset(0.47, 0.38),
      greeting: 'Niltze, ma titlatokan ika yolpakilistli.',
      words: const ['calli', 'atl', 'tonatiuh', 'tlalli', 'xochitl'],
    ),
    _language(
      name: 'Maya',
      color: const Color(0xFF8E4485),
      icon: Icons.auto_awesome,
      completedPerSection: 14,
      streakDays: 9,
      mapFocus: const Offset(0.74, 0.70),
      greeting: "Ki'imak in wóol in wilikech ka'a sut!",
      words: const ["ja'", 'kíin', 'naj', "xi'ik", 'yáax'],
    ),
    _language(
      name: 'Purépecha',
      color: const Color(0xFFE67E22),
      icon: Icons.eco,
      completedPerSection: 9,
      streakDays: 5,
      mapFocus: const Offset(0.43, 0.53),
      greeting: 'Juchari anapu, sigamos aprendiendo.',
      words: const ['ireta', 'kurhucha', 'tsïtsïki', 'uandani', 'juchari'],
    ),
    _language(
      name: 'Mixteco',
      color: const Color(0xFF7FB359),
      icon: Icons.grass,
      completedPerSection: 6,
      streakDays: 3,
      mapFocus: const Offset(0.55, 0.67),
      greeting: 'Kua va, vamos paso a paso.',
      words: const ['ñuu', 'yuku', 'ita', 'ndute', 'vehe'],
    ),
    _language(
      name: 'Otomí',
      color: const Color(0xFF3498DB),
      icon: Icons.people_alt_outlined,
      completedPerSection: 11,
      streakDays: 7,
      mapFocus: const Offset(0.50, 0.47),
      greeting: 'Hadi, avancemos con calma.',
      words: const ['hñä', 'dehe', 'ngu', 'zi', 'hyadi'],
    ),
  ];
}

CourseLanguage _language({
  required String name,
  required Color color,
  required IconData icon,
  required int completedPerSection,
  required int streakDays,
  required Offset mapFocus,
  required String greeting,
  required List<String> words,
}) {
  final sections = [
    _section(
      area: SkillArea.escritura,
      title: 'Escritura',
      nativeTitle: name == 'Maya' ? "Ts'íib" : 'Escribir',
      subtitle: 'Traza, completa y ordena palabras.',
      icon: Icons.edit_note,
      color: const Color(0xFFD1E9E9),
      completedActivities: completedPerSection,
      languageName: name,
      words: words,
    ),
    _section(
      area: SkillArea.lectura,
      title: 'Lectura',
      nativeTitle: name == 'Maya' ? 'Xook' : 'Leer',
      subtitle: 'Lee frases cortas y reconoce significado.',
      icon: Icons.menu_book_outlined,
      color: const Color(0xFFF8C7BC),
      completedActivities: (completedPerSection - 3).clamp(0, 50),
      languageName: name,
      words: words,
    ),
    _section(
      area: SkillArea.racha,
      title: 'Racha',
      nativeTitle: 'Días activos',
      subtitle: 'Registra tus ingresos diarios y mantén constancia.',
      icon: Icons.local_fire_department_outlined,
      color: const Color(0xFFFFE08A),
      completedActivities: streakDays.clamp(0, 50),
      languageName: name,
      words: words,
    ),
    _section(
      area: SkillArea.gramatica,
      title: 'Gramática',
      nativeTitle: name == 'Maya' ? "Ch'enxikin" : 'Gramática',
      subtitle: 'Construye frases con orden y sentido.',
      icon: Icons.psychology_alt_outlined,
      color: const Color(0xFFFFDCC1),
      completedActivities: (completedPerSection - 5).clamp(0, 50),
      languageName: name,
      words: words,
    ),
  ];
  final exp = sections.fold<int>(0, (total, section) => total + section.exp);

  return CourseLanguage(
    name: name,
    color: color,
    icon: icon,
    exp: exp,
    streakDays: streakDays,
    rank: rankForExp(exp),
    mapFocus: mapFocus,
    greeting: greeting,
    sections: sections,
  );
}

CourseSection _section({
  required SkillArea area,
  required String title,
  required String nativeTitle,
  required String subtitle,
  required IconData icon,
  required Color color,
  required int completedActivities,
  required String languageName,
  required List<String> words,
}) {
  final activities = _activities(
    area,
    languageName,
    words,
    completedActivities,
  );

  return CourseSection(
    area: area,
    title: title,
    nativeTitle: nativeTitle,
    subtitle: subtitle,
    icon: icon,
    color: color,
    exp: completedActivities * expPerActivity,
    activities: activities,
  );
}

List<CourseActivity> _activities(
  SkillArea area,
  String languageName,
  List<String> words,
  int completedActivities,
) {
  return ActivityApi.activitiesFor(
    languageName: languageName,
    area: area,
    fallbackWords: words,
  ).asMap().entries.map((entry) {
    final index = entry.key;
    final activity = entry.value;
    final status = index < completedActivities
        ? ActivityStatus.completed
        : index == completedActivities
        ? ActivityStatus.active
        : index < completedActivities + 8
        ? ActivityStatus.available
        : ActivityStatus.locked;

    return activity.copyWith(
      title: '${index + 1}. ${activity.title}',
      status: status,
    );
  }).toList();
}
