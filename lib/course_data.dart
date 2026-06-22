import 'package:flutter/material.dart';

import 'activity_api.dart';
export 'course_models.dart';
import 'course_models.dart';
import 'user_progress_controller.dart';

List<CourseLanguage> buildCourses({UserProgress? progress}) {
  final userProgress = progress ?? UserProgressController.currentProgress;

  return [
    _language(
      name: 'Náhuatl',
      color: const Color(0xFF1A948E),
      icon: Icons.waves,
      imageAsset: 'assets/images/logo_nahualt.png',
      progress: userProgress,
      mapFocus: const Offset(0.62, 0.58),
      greeting: 'Niltze, ma titlatokan ika yolpakilistli.',
      words: const ['calli', 'atl', 'tonatiuh', 'tlalli', 'xochitl'],
    ),
    _language(
      name: 'Maya',
      color: const Color(0xFF8E4485),
      icon: Icons.auto_awesome,
      imageAsset: 'assets/images/logo_maya.png',
      progress: userProgress,
      mapFocus: const Offset(0.83, 0.47),
      greeting: "Ki'imak in wóol in wilikech ka'a sut!",
      words: const ["ja'", 'kíin', 'naj', "xi'ik", 'yáax'],
    ),
    _language(
      name: 'Purépecha',
      color: const Color(0xFF7FB359),
      icon: Icons.eco,
      imageAsset: 'assets/images/logo_purepecha.png',
      progress: userProgress,
      mapFocus: const Offset(0.45, 0.61),
      greeting: 'Juchari anapu, sigamos aprendiendo.',
      words: const ['ireta', 'kurhucha', 'tsïtsïki', 'uandani', 'juchari'],
    ),
    _language(
      name: 'Mixteco',
      color: const Color(0xFFE67E22),
      icon: Icons.grass,
      imageAsset: 'assets/images/logo_mixteco.png',
      progress: userProgress,
      mapFocus: const Offset(0.55, 0.72),
      greeting: 'Kua va, vamos paso a paso.',
      words: const ['ñuu', 'yuku', 'ita', 'ndute', 'vehe'],
    ),
    _language(
      name: 'Otomí',
      color: const Color(0xFF3498DB),
      icon: Icons.people_alt_outlined,
      imageAsset: 'assets/images/logo_otomi.png',
      progress: userProgress,
      mapFocus: const Offset(0.53, 0.59),
      greeting: 'Hadi, avancemos con calma.',
      words: const ['hñä', 'dehe', 'ngu', 'zi', 'hyadi'],
    ),
  ];
}

CourseLanguage _language({
  required String name,
  required Color color,
  required IconData icon,
  required String imageAsset,
  required UserProgress progress,
  required Offset mapFocus,
  required String greeting,
  required List<String> words,
}) {
  final sections = [
    _section(
      area: SkillArea.escritura,
      title: 'Escritura',
      nativeTitle: name == 'Maya' ? "Ts'íib" : 'Escribir',
      subtitle: 'Abecedario, sonidos, trazos y palabras.',
      icon: Icons.edit_note,
      imageAsset: 'assets/images/logo_escritura.png',
      color: const Color(0xFFD1E9E9),
      progress: progress,
      languageName: name,
      words: words,
    ),
    _section(
      area: SkillArea.lectura,
      title: 'Lectura',
      nativeTitle: name == 'Maya' ? 'Xook' : 'Leer',
      subtitle: 'Cuentos, dialogos y comprension.',
      icon: Icons.menu_book_outlined,
      imageAsset: 'assets/images/logo_lectura.png',
      color: const Color(0xFFF8C7BC),
      progress: progress,
      languageName: name,
      words: words,
    ),
    _section(
      area: SkillArea.racha,
      title: 'Racha',
      nativeTitle: 'Días activos',
      subtitle: 'Sube automaticamente al completar actividades.',
      icon: Icons.local_fire_department_outlined,
      imageAsset: 'assets/images/Logo_racha.png',
      color: const Color(0xFFFFE08A),
      progress: progress,
      languageName: name,
      words: words,
    ),
    _section(
      area: SkillArea.gramatica,
      title: 'Gramática',
      nativeTitle: name == 'Maya' ? "Ch'enxikin" : 'Gramática',
      subtitle: 'Ordena frases y descubre patrones.',
      icon: Icons.psychology_alt_outlined,
      imageAsset: 'assets/images/logo_gramatica.png',
      color: const Color(0xFFFFDCC1),
      progress: progress,
      languageName: name,
      words: words,
    ),
  ];
  final exp = sections.fold<int>(0, (total, section) => total + section.exp);
  final streakDays = progress.streakDays(name);

  return CourseLanguage(
    name: name,
    color: color,
    icon: icon,
    imageAsset: imageAsset,
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
  required String imageAsset,
  required Color color,
  required UserProgress progress,
  required String languageName,
  required List<String> words,
}) {
  final activities = area == SkillArea.racha
      ? <CourseActivity>[]
      : _activities(
          area,
          languageName,
          words,
          progress.completedActivities(languageName, area),
        );
  final completedActivities = activities
      .where((activity) => activity.status == ActivityStatus.completed)
      .length;

  return CourseSection(
    area: area,
    title: title,
    nativeTitle: nativeTitle,
    subtitle: subtitle,
    icon: icon,
    imageAsset: imageAsset,
    color: color,
    exp: completedActivities * expPerActivity,
    learningTips: _learningTips(area, languageName),
    activities: activities,
  );
}

List<String> _learningTips(SkillArea area, String languageName) {
  return switch (area) {
    SkillArea.escritura => [
      'Observa el abecedario del dialecto y copia primero las letras que se repiten.',
      'Separa la palabra en sonidos cortos: inicio, centro y final.',
      'Compara la palabra con su significado en espanol antes de escribir.',
      'Practica con trazos lentos: mirar, decir, tapar y escribir.',
    ],
    SkillArea.lectura => [
      'Lee el cuento primero en $languageName y luego revisa la traduccion en espanol.',
      'Busca palabras conocidas dentro del texto antes de contestar.',
      'Identifica quien aparece, que hace y donde ocurre la historia.',
      'En los dialogos, reconoce saludos, nombres y lugares.',
    ],
    SkillArea.gramatica => [
      'Fijate en el orden: quien habla, que accion hace y que objeto aparece.',
      'Compara la frase en $languageName con su version en espanol.',
      'Las particulas pequenas pueden cambiar una pregunta, negacion o lugar.',
      'Ordena primero las palabras conocidas y deja al final las nuevas.',
    ],
    SkillArea.racha => [
      'Tu racha sube automaticamente cuando completas actividades nuevas.',
      'No necesitas hacer check-in: sigue aprendiendo y la constancia se registra.',
    ],
  };
}

List<CourseActivity> _activities(
  SkillArea area,
  String languageName,
  List<String> words,
  Set<String> completedActivities,
) {
  var nextActivityAssigned = false;
  final completedCount = completedActivities.length;

  return ActivityApi.activitiesFor(
    languageName: languageName,
    area: area,
    fallbackWords: words,
  ).asMap().entries.map((entry) {
    final index = entry.key;
    final activity = entry.value;
    late final ActivityStatus status;

    if (completedActivities.contains(activity.id)) {
      status = ActivityStatus.completed;
    } else if (!nextActivityAssigned) {
      status = ActivityStatus.active;
      nextActivityAssigned = true;
    } else if (index < completedCount + 8) {
      status = ActivityStatus.available;
    } else {
      status = ActivityStatus.locked;
    }

    return activity.copyWith(
      title: '${index + 1}. ${activity.title}',
      status: status,
    );
  }).toList();
}
