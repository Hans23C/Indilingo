import 'package:flutter/material.dart';

enum SkillArea { escritura, lectura, hablado, gramatica }

enum ActivityStatus { completed, active, available, locked }

class CourseLanguage {
  final String name;
  final Color color;
  final IconData icon;
  final double progress;
  final Offset mapFocus;
  final String greeting;
  final List<CourseSection> sections;

  const CourseLanguage({
    required this.name,
    required this.color,
    required this.icon,
    required this.progress,
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
  final double progress;
  final List<CourseActivity> activities;

  const CourseSection({
    required this.area,
    required this.title,
    required this.nativeTitle,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.progress,
    required this.activities,
  });
}

class CourseActivity {
  final String title;
  final String instruction;
  final String prompt;
  final String answer;
  final ActivityStatus status;

  const CourseActivity({
    required this.title,
    required this.instruction,
    required this.prompt,
    required this.answer,
    required this.status,
  });
}

List<CourseLanguage> buildCourses() {
  return [
    _language(
      name: 'Náhuatl',
      color: const Color(0xFF1A948E),
      icon: Icons.waves,
      progress: 0.90,
      mapFocus: const Offset(0.47, 0.38),
      greeting: 'Niltze, ma titlatokan ika yolpakilistli.',
      words: const ['calli', 'atl', 'tonatiuh', 'tlalli', 'xochitl'],
    ),
    _language(
      name: 'Maya',
      color: const Color(0xFF8E4485),
      icon: Icons.auto_awesome,
      progress: 0.85,
      mapFocus: const Offset(0.74, 0.70),
      greeting: "Ki'imak in wóol in wilikech ka'a sut!",
      words: const ["ja'", 'kíin', 'naj', "xi'ik", 'yáax'],
    ),
    _language(
      name: 'Purépecha',
      color: const Color(0xFFE67E22),
      icon: Icons.eco,
      progress: 0.72,
      mapFocus: const Offset(0.43, 0.53),
      greeting: 'Juchari anapu, sigamos aprendiendo.',
      words: const ['ireta', 'kurhucha', 'tsïtsïki', 'uandani', 'juchari'],
    ),
    _language(
      name: 'Mixteco',
      color: const Color(0xFF7FB359),
      icon: Icons.grass,
      progress: 0.68,
      mapFocus: const Offset(0.55, 0.67),
      greeting: 'Kua va, vamos paso a paso.',
      words: const ['ñuu', 'yuku', 'ita', 'ndute', 'vehe'],
    ),
    _language(
      name: 'Otomí',
      color: const Color(0xFF3498DB),
      icon: Icons.people_alt_outlined,
      progress: 0.76,
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
  required double progress,
  required Offset mapFocus,
  required String greeting,
  required List<String> words,
}) {
  return CourseLanguage(
    name: name,
    color: color,
    icon: icon,
    progress: progress,
    mapFocus: mapFocus,
    greeting: greeting,
    sections: [
      _section(
        area: SkillArea.escritura,
        title: 'Escritura',
        nativeTitle: name == 'Maya' ? "Ts'íib" : 'Escribir',
        subtitle: 'Traza, completa y ordena palabras.',
        icon: Icons.edit_note,
        color: const Color(0xFFD1E9E9),
        progress: (progress + 0.04).clamp(0.0, 1.0),
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
        progress: (progress - 0.08).clamp(0.0, 1.0),
        languageName: name,
        words: words,
      ),
      _section(
        area: SkillArea.hablado,
        title: 'Hablado',
        nativeTitle: name == 'Maya' ? "T'aan" : 'Hablar',
        subtitle: 'Practica pronunciación y conversación.',
        icon: Icons.record_voice_over_outlined,
        color: const Color(0xFFF4AFDE),
        progress: (progress - 0.14).clamp(0.0, 1.0),
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
        progress: (progress - 0.18).clamp(0.0, 1.0),
        languageName: name,
        words: words,
      ),
    ],
  );
}

CourseSection _section({
  required SkillArea area,
  required String title,
  required String nativeTitle,
  required String subtitle,
  required IconData icon,
  required Color color,
  required double progress,
  required String languageName,
  required List<String> words,
}) {
  return CourseSection(
    area: area,
    title: title,
    nativeTitle: nativeTitle,
    subtitle: subtitle,
    icon: icon,
    color: color,
    progress: progress,
    activities: _activities(area, languageName, words),
  );
}

List<CourseActivity> _activities(
  SkillArea area,
  String languageName,
  List<String> words,
) {
  final labels = switch (area) {
    SkillArea.escritura => [
      'Copia guiada',
      'Completa vocales',
      'Ordena sílabas',
      'Dictado corto',
      'Escribe el saludo',
      'Une palabra e imagen',
      'Corrige el acento',
      'Forma una frase',
      'Mini diario',
      'Repaso escrito',
    ],
    SkillArea.lectura => [
      'Reconoce palabra',
      'Lee y elige',
      'Frase con imagen',
      'Pregunta rápida',
      'Encuentra el intruso',
      'Lee en voz baja',
      'Orden de lectura',
      'Comprensión corta',
      'Historieta breve',
      'Repaso lector',
    ],
    SkillArea.hablado => [
      'Repite sonidos',
      'Saludo oral',
      'Pregunta y respuesta',
      'Pronuncia palabra',
      'Ritmo de frase',
      'Conversación corta',
      'Describe imagen',
      'Escucha y repite',
      'Presentación breve',
      'Repaso hablado',
    ],
    SkillArea.gramatica => [
      'Orden de frase',
      'Sujeto y acción',
      'Plural básico',
      'Tiempo presente',
      'Partículas comunes',
      'Pregunta simple',
      'Negación básica',
      'Conecta ideas',
      'Corrige frase',
      'Repaso gramatical',
    ],
  };

  return List.generate(10, (index) {
    final word = words[index % words.length];
    final status = index < 3
        ? ActivityStatus.completed
        : index == 3
        ? ActivityStatus.active
        : index < 8
        ? ActivityStatus.available
        : ActivityStatus.locked;

    return CourseActivity(
      title: '${index + 1}. ${labels[index]}',
      instruction: _instruction(area, languageName),
      prompt: _prompt(area, word),
      answer: word,
      status: status,
    );
  });
}

String _instruction(SkillArea area, String languageName) {
  return switch (area) {
    SkillArea.escritura =>
      'Escribe con cuidado la palabra de práctica en $languageName.',
    SkillArea.lectura =>
      'Lee la frase y selecciona la palabra clave en $languageName.',
    SkillArea.hablado =>
      'Di la palabra en voz alta y repítela tres veces con ritmo natural.',
    SkillArea.gramatica =>
      'Observa el orden de la frase y arma una versión correcta.',
  };
}

String _prompt(SkillArea area, String word) {
  return switch (area) {
    SkillArea.escritura => 'Palabra para escribir: $word',
    SkillArea.lectura => 'Encuentra la palabra "$word" dentro de una frase.',
    SkillArea.hablado => 'Practica la pronunciación de "$word".',
    SkillArea.gramatica => 'Construye una frase breve usando "$word".',
  };
}
