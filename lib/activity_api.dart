import 'course_models.dart';

class ActivityApi {
  const ActivityApi._();

  static List<CourseActivity> activitiesFor({
    required String languageName,
    required SkillArea area,
    required List<String> fallbackWords,
  }) {
    final words = _vocabulary[languageName] ?? _fromFallback(fallbackWords);
    final builder = switch (area) {
      SkillArea.escritura => _writingActivity,
      SkillArea.lectura => _readingActivity,
      SkillArea.racha => _streakActivity,
      SkillArea.gramatica => _grammarActivity,
    };

    return List.generate(maxActivitiesPerSection, (index) {
      final word = words[index % words.length];
      return builder(languageName, word, index);
    });
  }

  static List<_VocabularyItem> _fromFallback(List<String> words) {
    return words
        .map((word) => _VocabularyItem(term: word, meaning: 'palabra'))
        .toList();
  }

  static CourseActivity _writingActivity(
    String languageName,
    _VocabularyItem word,
    int index,
  ) {
    const labels = [
      'Copia guiada',
      'Completa la palabra',
      'Ordena sonidos',
      'Dictado corto',
      'Escribe el saludo',
      'Une palabra y significado',
      'Corrige la escritura',
      'Forma una frase',
      'Mini diario',
      'Repaso escrito',
    ];

    return CourseActivity(
      id: '$languageName-escritura-$index',
      title: _numberedLabel(labels, index),
      type: ActivityType.writing,
      instruction:
          'Escribe la palabra en $languageName que corresponde al significado.',
      prompt: 'Significado: ${word.meaning}',
      answer: word.term,
      options: const [],
      successMessage: 'Muy bien. Escribiste ${word.term} correctamente.',
      status: ActivityStatus.available,
    );
  }

  static CourseActivity _readingActivity(
    String languageName,
    _VocabularyItem word,
    int index,
  ) {
    const labels = [
      'Reconoce palabra',
      'Lee y elige',
      'Frase con imagen',
      'Pregunta rapida',
      'Encuentra el intruso',
      'Lee en voz baja',
      'Orden de lectura',
      'Comprension corta',
      'Historieta breve',
      'Repaso lector',
    ];

    return CourseActivity(
      id: '$languageName-lectura-$index',
      title: _numberedLabel(labels, index),
      type: ActivityType.multipleChoice,
      instruction: 'Lee la pista y elige la palabra correcta en $languageName.',
      prompt: 'Selecciona la palabra que significa "${word.meaning}".',
      answer: word.term,
      options: _wordOptions(word.term, languageName),
      successMessage: 'Correcto. ${word.term} significa ${word.meaning}.',
      status: ActivityStatus.available,
    );
  }

  static CourseActivity _streakActivity(
    String languageName,
    _VocabularyItem word,
    int index,
  ) {
    const labels = [
      'Ingreso del día',
      'Constancia diaria',
      'Repaso de racha',
      'Memoria del día',
      'Meta cumplida',
      'Paso de comunidad',
      'Palabra del día',
      'Reto de constancia',
      'Avance diario',
      'Fuego de aprendizaje',
    ];

    return CourseActivity(
      id: '$languageName-racha-$index',
      title: _numberedLabel(labels, index),
      type: ActivityType.streak,
      instruction: 'Registra tu práctica diaria para mantener tu racha.',
      prompt:
          'Repasa la palabra "${word.term}" (${word.meaning}) y confirma tu ingreso de hoy.',
      answer: 'racha',
      options: const [],
      successMessage: 'Racha registrada. La constancia también suma EXP.',
      status: ActivityStatus.available,
    );
  }

  static CourseActivity _grammarActivity(
    String languageName,
    _VocabularyItem word,
    int index,
  ) {
    const labels = [
      'Orden de frase',
      'Sujeto y accion',
      'Plural basico',
      'Tiempo presente',
      'Particulas comunes',
      'Pregunta simple',
      'Negacion basica',
      'Conecta ideas',
      'Corrige frase',
      'Repaso gramatical',
    ];
    final sentence = 'Yo aprendo ${word.term}';

    return CourseActivity(
      id: '$languageName-gramatica-$index',
      title: _numberedLabel(labels, index),
      type: ActivityType.sentenceOrder,
      instruction:
          'Toca las palabras en el orden correcto para formar la frase.',
      prompt: 'Forma: "$sentence".',
      answer: sentence,
      options: [word.term, 'aprendo', 'Yo'],
      successMessage: 'Frase completa: $sentence.',
      status: ActivityStatus.available,
    );
  }

  static List<String> _wordOptions(String answer, String languageName) {
    final languageWords = _vocabulary[languageName] ?? const [];
    final options = <String>[answer];

    for (final item in languageWords) {
      if (item.term != answer && options.length < 4) {
        options.add(item.term);
      }
    }

    while (options.length < 4) {
      options.add(
        ['saludo', 'camino', 'comunidad', 'casa'][options.length - 1],
      );
    }

    return options;
  }

  static String _numberedLabel(List<String> labels, int index) {
    final label = labels[index % labels.length];
    final round = (index ~/ labels.length) + 1;
    return round == 1 ? label : '$label $round';
  }

  static const Map<String, List<_VocabularyItem>> _vocabulary = {
    'Náhuatl': [
      _VocabularyItem(term: 'calli', meaning: 'casa'),
      _VocabularyItem(term: 'atl', meaning: 'agua'),
      _VocabularyItem(term: 'tonatiuh', meaning: 'sol'),
      _VocabularyItem(term: 'tlalli', meaning: 'tierra'),
      _VocabularyItem(term: 'xochitl', meaning: 'flor'),
    ],
    'Maya': [
      _VocabularyItem(term: "ja'", meaning: 'agua'),
      _VocabularyItem(term: 'kíin', meaning: 'sol'),
      _VocabularyItem(term: 'naj', meaning: 'casa'),
      _VocabularyItem(term: "xi'ik", meaning: 'ala'),
      _VocabularyItem(term: 'yáax', meaning: 'verde'),
    ],
    'Purépecha': [
      _VocabularyItem(term: 'ireta', meaning: 'pueblo'),
      _VocabularyItem(term: 'kurhucha', meaning: 'pez'),
      _VocabularyItem(term: 'tsïtsïki', meaning: 'flor'),
      _VocabularyItem(term: 'uandani', meaning: 'hablar'),
      _VocabularyItem(term: 'juchari', meaning: 'nuestro'),
    ],
    'Mixteco': [
      _VocabularyItem(term: 'ñuu', meaning: 'pueblo'),
      _VocabularyItem(term: 'yuku', meaning: 'cerro'),
      _VocabularyItem(term: 'ita', meaning: 'flor'),
      _VocabularyItem(term: 'ndute', meaning: 'agua'),
      _VocabularyItem(term: 'vehe', meaning: 'casa'),
    ],
    'Otomí': [
      _VocabularyItem(term: 'hñä', meaning: 'lengua'),
      _VocabularyItem(term: 'dehe', meaning: 'agua'),
      _VocabularyItem(term: 'ngu', meaning: 'casa'),
      _VocabularyItem(term: 'zi', meaning: 'pequeno'),
      _VocabularyItem(term: 'hyadi', meaning: 'sol'),
    ],
  };
}

class _VocabularyItem {
  final String term;
  final String meaning;

  const _VocabularyItem({required this.term, required this.meaning});
}
