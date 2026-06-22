import 'course_models.dart';

class ActivityApi {
  const ActivityApi._();

  static List<CourseActivity> activitiesFor({
    required String languageName,
    required SkillArea area,
    required List<String> fallbackWords,
  }) {
    final content = _contentFor(languageName, fallbackWords);

    return List.generate(maxActivitiesPerSection, (index) {
      final word = _progressiveWord(content, index);
      return switch (area) {
        SkillArea.escritura => _writingActivity(
          languageName,
          content,
          word,
          index,
        ),
        SkillArea.lectura => _readingActivity(
          languageName,
          content,
          word,
          index,
        ),
        SkillArea.racha => _streakActivity(languageName, content, word, index),
        SkillArea.gramatica => _grammarActivity(
          languageName,
          content,
          word,
          index,
        ),
      };
    });
  }

  static CourseActivity _writingActivity(
    String languageName,
    _LanguageContent content,
    _VocabularyItem word,
    int index,
  ) {
    const labels = [
      'Abecedario base',
      'Sonido escondido',
      'Silabas y partes',
      'Palabra incompleta',
      'Copia con memoria',
      'Dictado visual',
      'Palabra y significado',
      'Frase guiada',
      'Frase sin pista',
      'Reto final escrito',
    ];
    final pattern = index % 10;
    final stage = index ~/ 10;
    final partner = _wordAt(content, index + 3);
    final sentence = _sentenceFor(content, word);
    final hidden = _hideMiddle(word.term);
    final title = '${labels[pattern]}: ${word.meaning}';

    if (pattern == 0) {
      return CourseActivity(
        id: '$languageName-escritura-$index',
        title: title,
        type: ActivityType.multipleChoice,
        instruction: 'Usa el abecedario para reconocer sonidos.',
        prompt:
            'Abecedario: ${content.alphabet}\n\nElige la palabra que contiene el sonido "${_focusSound(word.term, stage)}".',
        answer: word.term,
        options: _wordOptions(word.term, content, offset: index),
        helperText:
            'No basta con mirar la primera letra: busca el sonido dentro de toda la palabra.',
        successMessage: 'Bien. Reconociste un sonido de ${word.term}.',
        status: ActivityStatus.available,
      );
    }

    if (pattern == 1 || pattern == 2 || pattern == 3) {
      return CourseActivity(
        id: '$languageName-escritura-$index',
        title: title,
        type: ActivityType.missingWord,
        instruction: 'Completa la palabra en $languageName.',
        prompt:
            'Palabra incompleta: $hidden\nSignificado: ${word.meaning}\nPalabra cercana para comparar: ${partner.term} (${partner.meaning}).',
        answer: word.term,
        options: _wordOptions(word.term, content, offset: index + stage),
        helperText:
            'Compara las letras que cambian entre dos palabras. Esto prepara la escritura sin copiar a ciegas.',
        successMessage: 'Excelente. Completaste ${word.term}.',
        status: ActivityStatus.available,
      );
    }

    if (pattern == 7 || pattern == 8 || pattern == 9 || stage >= 3) {
      return CourseActivity(
        id: '$languageName-escritura-$index',
        title: title,
        type: ActivityType.writing,
        instruction: pattern == 9
            ? 'Escribe la frase completa sin separar mal las palabras.'
            : 'Escribe la mini frase completa.',
        prompt:
            'Frase modelo: "$sentence"\nTraduccion: Yo aprendo ${word.meaning}.\nReto: escribe la frase completa.',
        answer: sentence,
        options: const [],
        helperText:
            'Revisa espacios y orden. Si dudas, lee la frase completa antes de escribir.',
        successMessage: 'Muy bien. Tu frase quedo completa.',
        status: ActivityStatus.available,
      );
    }

    return CourseActivity(
      id: '$languageName-escritura-$index',
      title: title,
      type: ActivityType.writing,
      instruction:
          'Escribe la palabra en $languageName que corresponde al significado.',
      prompt:
          'Significado principal: ${word.meaning}\nPista comparativa: no es ${partner.term} (${partner.meaning}).',
      answer: word.term,
      options: const [],
      helperText:
          'Mira la palabra en tu mente, dila, tapala y escribe. Ya no es solo reconocer: ahora produces.',
      successMessage: 'Muy bien. Escribiste ${word.term} correctamente.',
      status: ActivityStatus.available,
    );
  }

  static CourseActivity _readingActivity(
    String languageName,
    _LanguageContent content,
    _VocabularyItem word,
    int index,
  ) {
    const labels = [
      'Cuento corto',
      'Personaje y accion',
      'Dialogo amable',
      'Palabra clave',
      'Traduccion atenta',
      'Lugar del cuento',
      'Idea principal',
      'Orden lector',
      'Pregunta del texto',
      'Reto de inferencia',
    ];
    final pattern = index % 10;
    final story = content.stories[index % content.stories.length];
    final dialogue = content.dialogues[index % content.dialogues.length];
    final partner = _wordAt(content, index + 4);
    final title = '${labels[pattern]}: ${word.meaning}';

    if (pattern == 0 || pattern == 1 || pattern == 6 || pattern == 8) {
      return CourseActivity(
        id: '$languageName-lectura-$index',
        title: title,
        type: ActivityType.readingStory,
        instruction: 'Lee el cuento en $languageName y revisa su traduccion.',
        prompt: _readingQuestion(pattern, story, word),
        answer: _readingAnswer(pattern, story, word),
        options: _readingOptions(pattern, story, word, content),
        helperText:
            'Lee dos veces: primero para entender la historia, despues para encontrar la evidencia.',
        readingText: _readingText(story.nativeText, word, partner),
        translationText: _readingText(story.spanishText, word, partner),
        successMessage: 'Correcto. Comprendiste el cuento.',
        status: ActivityStatus.available,
      );
    }

    if (pattern == 2 || pattern == 5) {
      return CourseActivity(
        id: '$languageName-lectura-$index',
        title: title,
        type: ActivityType.dialogue,
        instruction: 'Lee el dialogo y elige la respuesta correcta.',
        prompt: dialogue.question,
        answer: dialogue.answer,
        options: dialogue.options,
        helperText: 'Pista: los saludos y nombres ayudan a entender la escena.',
        readingText: _readingText(dialogue.nativeText, word, partner),
        translationText: _readingText(dialogue.spanishText, word, partner),
        successMessage: 'Muy bien. Entendiste el dialogo.',
        status: ActivityStatus.available,
      );
    }

    if (pattern == 7) {
      final sentence = _sentenceFor(content, word);
      return CourseActivity(
        id: '$languageName-lectura-$index',
        title: title,
        type: ActivityType.sentenceOrder,
        instruction: 'Ordena la lectura para formar una frase con sentido.',
        prompt:
            'Forma la frase que significa una idea de aprendizaje con "${word.meaning}".',
        answer: sentence,
        options: _shuffledSentenceParts(content, word, index),
        helperText:
            'No ordenes al azar: busca quien habla, luego accion y despues palabra clave.',
        readingText: _readingText(story.nativeText, word, partner),
        translationText: _readingText(story.spanishText, word, partner),
        successMessage: 'Lectura ordenada correctamente.',
        status: ActivityStatus.available,
      );
    }

    return CourseActivity(
      id: '$languageName-lectura-$index',
      title: title,
      type: ActivityType.multipleChoice,
      instruction: 'Lee el texto y elige la palabra correcta en $languageName.',
      prompt:
          'Busca en la lectura una palabra relacionada con "${word.meaning}".',
      answer: word.term,
      options: _wordOptions(word.term, content, offset: index),
      helperText:
          'La respuesta se apoya en el texto, no solo en memoria. Revisa la traduccion.',
      readingText: _readingText(story.nativeText, word, partner),
      translationText: _readingText(story.spanishText, word, partner),
      successMessage: 'Correcto. ${word.term} significa ${word.meaning}.',
      status: ActivityStatus.available,
    );
  }

  static CourseActivity _streakActivity(
    String languageName,
    _LanguageContent content,
    _VocabularyItem word,
    int index,
  ) {
    const labels = [
      'Repaso del dia',
      'Memoria diaria',
      'Repaso de racha',
      'Palabra recordada',
      'Meta de aprendizaje',
      'Paso de comunidad',
      'Palabra del dia',
      'Reto de constancia',
      'Avance diario',
      'Fuego de aprendizaje',
    ];

    final partner = _wordAt(content, index + 2);

    return CourseActivity(
      id: '$languageName-racha-$index',
      title: '${labels[index % labels.length]}: ${word.meaning}',
      type: ActivityType.multipleChoice,
      instruction: 'Repasa una palabra para fortalecer tu racha.',
      prompt:
          'Repaso mixto: cual palabra significa "${word.meaning}" y no "${partner.meaning}"?',
      answer: word.term,
      options: _wordOptions(word.term, content, offset: index),
      helperText:
          'Tu racha aumenta automaticamente cuando completas actividades nuevas del dialecto.',
      successMessage: 'Repaso completado. Tu constancia sigue creciendo.',
      status: ActivityStatus.available,
    );
  }

  static CourseActivity _grammarActivity(
    String languageName,
    _LanguageContent content,
    _VocabularyItem word,
    int index,
  ) {
    const labels = [
      'Partes de frase',
      'Quien habla',
      'Accion',
      'Orden de frase',
      'Palabra clave',
      'Comparar traduccion',
      'Pregunta simple',
      'Frase con pista',
      'Corrige frase',
      'Reto de frase',
    ];
    final pattern = index % 10;
    final stage = index ~/ 10;
    final sentence = _sentenceFor(content, word);
    final title = '${labels[pattern]}: ${word.meaning}';

    if (pattern == 0 || pattern == 1 || pattern == 2 || pattern == 4) {
      final asksAction = pattern == 2;
      final asksSubject = pattern == 1 || pattern == 0;
      final answer = asksAction
          ? content.basicVerb
          : asksSubject
          ? content.basicSubject
          : word.term;
      return CourseActivity(
        id: '$languageName-gramatica-$index',
        title: title,
        type: ActivityType.multipleChoice,
        instruction: 'Aprende las partes basicas de una frase.',
        prompt: 'Frase modelo: "$sentence"\n\n${_grammarQuestion(pattern)}',
        answer: answer,
        options: _grammarOptions(content, word, answer, index),
        helperText:
            'No memorices solo una respuesta: identifica la funcion de cada palabra dentro de la frase.',
        successMessage: 'Correcto. Identificaste una parte de la frase.',
        status: ActivityStatus.available,
      );
    }

    if (pattern == 5 || pattern == 6) {
      return CourseActivity(
        id: '$languageName-gramatica-$index',
        title: title,
        type: ActivityType.multipleChoice,
        instruction: 'Compara la frase con su traduccion.',
        prompt:
            'Frase: "$sentence"\nTraduccion: Yo aprendo ${word.meaning}.\nQue palabra representa "${word.meaning}"?',
        answer: word.term,
        options: _wordOptions(word.term, content, offset: index),
        helperText:
            'Relaciona cada parte de la frase con su significado en espanol.',
        successMessage: 'Bien. Conectaste gramatica y significado.',
        status: ActivityStatus.available,
      );
    }

    if (pattern == 8 || pattern == 9 || stage >= 3) {
      return CourseActivity(
        id: '$languageName-gramatica-$index',
        title: title,
        type: ActivityType.writing,
        instruction: pattern == 9
            ? 'Escribe la frase completa sin ayuda de opciones.'
            : 'Copia y corrige la frase.',
        prompt:
            'Frase correcta: "$sentence".\nPista: conserva el orden sujeto + accion + palabra clave.',
        answer: sentence,
        options: const [],
        helperText:
            'La gramatica se aprende comparando: palabra conocida + accion + idea nueva.',
        successMessage: 'Frase corregida y escrita.',
        status: ActivityStatus.available,
      );
    }

    return CourseActivity(
      id: '$languageName-gramatica-$index',
      title: title,
      type: ActivityType.sentenceOrder,
      instruction:
          'Toca las palabras en el orden correcto para formar la frase.',
      prompt: 'Forma: "$sentence".',
      answer: sentence,
      options: _shuffledSentenceParts(content, word, index),
      helperText:
          'Apoyo gramatical: sujeto + accion + palabra clave. Traduccion: Yo aprendo ${word.meaning}.',
      successMessage: 'Frase completa: $sentence.',
      status: ActivityStatus.available,
    );
  }

  static List<String> _wordOptions(
    String answer,
    _LanguageContent content, {
    int offset = 0,
  }) {
    final options = <String>[answer];
    final words = [
      ...content.words.skip(offset % content.words.length),
      ...content.words.take(offset % content.words.length),
    ];

    for (final item in words) {
      if (item.term != answer && options.length < 4) {
        options.add(item.term);
      }
    }

    while (options.length < 4) {
      options.add(
        ['saludo', 'camino', 'comunidad', 'casa'][options.length - 1],
      );
    }

    return _rotate(options, offset);
  }

  static _VocabularyItem _wordAt(_LanguageContent content, int index) {
    return content.words[index % content.words.length];
  }

  static _VocabularyItem _progressiveWord(_LanguageContent content, int index) {
    final pattern = index % 10;
    final stage = index ~/ 10;
    return content.words[((pattern * 3) + stage) % content.words.length];
  }

  static String _sentenceFor(_LanguageContent content, _VocabularyItem word) {
    return '${content.basicSubject} ${content.basicVerb} ${word.term}';
  }

  static List<String> _shuffledSentenceParts(
    _LanguageContent content,
    _VocabularyItem word,
    int index,
  ) {
    return _rotate([word.term, content.basicVerb, content.basicSubject], index);
  }

  static String _focusSound(String value, int stage) {
    if (value.length <= 2) return value[0];
    final position = stage % value.length;
    return value[position];
  }

  static String _readingQuestion(
    int pattern,
    _Story story,
    _VocabularyItem word,
  ) {
    return switch (pattern) {
      1 => 'Segun el cuento, que detalle ayuda a entender la historia?',
      6 => 'Cual es una idea importante del texto?',
      8 => 'Que respuesta se puede comprobar leyendo el cuento?',
      _ => story.question,
    };
  }

  static String _readingAnswer(
    int pattern,
    _Story story,
    _VocabularyItem word,
  ) {
    return switch (pattern) {
      1 || 6 || 8 => word.term,
      _ => story.answer,
    };
  }

  static List<String> _readingOptions(
    int pattern,
    _Story story,
    _VocabularyItem word,
    _LanguageContent content,
  ) {
    if (pattern == 1 || pattern == 6 || pattern == 8) {
      return _wordOptions(word.term, content);
    }
    return story.options;
  }

  static String _readingText(
    String baseText,
    _VocabularyItem word,
    _VocabularyItem partner,
  ) {
    return '$baseText\n\nMision de lectura: busca "${word.term}" (${word.meaning}) y comparala con "${partner.term}" (${partner.meaning}).';
  }

  static String _grammarQuestion(int pattern) {
    return switch (pattern) {
      1 => 'Cual palabra muestra quien participa?',
      2 => 'Cual palabra indica la accion?',
      4 => 'Cual es la palabra clave de significado?',
      _ => 'Cual palabra funciona como sujeto?',
    };
  }

  static List<String> _grammarOptions(
    _LanguageContent content,
    _VocabularyItem word,
    String answer,
    int index,
  ) {
    final options = <String>{
      answer,
      content.basicSubject,
      content.basicVerb,
      word.term,
      _wordAt(content, index + 1).term,
    }.toList();
    while (options.length < 4) {
      options.add(_wordAt(content, index + options.length).term);
    }
    return _rotate(options.take(4).toList(), index);
  }

  static List<T> _rotate<T>(List<T> values, int offset) {
    if (values.isEmpty) return values;
    final shift = offset % values.length;
    return [...values.skip(shift), ...values.take(shift)];
  }

  static String _hideMiddle(String value) {
    if (value.length <= 2) return '${value[0]}_';
    return '${value[0]}${'_' * (value.length - 2)}${value[value.length - 1]}';
  }

  static _LanguageContent _contentFor(
    String languageName,
    List<String> fallbackWords,
  ) {
    final normalized = languageName.toLowerCase();
    if (normalized.contains('huatl')) return _content['nahuatl']!;
    if (normalized.contains('maya')) return _content['maya']!;
    if (normalized.contains('pur')) return _content['purepecha']!;
    if (normalized.contains('mixteco')) return _content['mixteco']!;
    if (normalized.contains('otom')) return _content['otomi']!;
    return _LanguageContent.fromFallback(fallbackWords);
  }

  static const Map<String, _LanguageContent> _content = {
    'nahuatl': _LanguageContent(
      alphabet: 'a, ch, e, i, k, ku, l, m, n, o, p, s, t, tl, tz, x, y',
      basicSubject: 'Ne',
      basicVerb: 'nimomachtia',
      words: [
        _VocabularyItem(term: 'calli', meaning: 'casa'),
        _VocabularyItem(term: 'atl', meaning: 'agua'),
        _VocabularyItem(term: 'tonatiuh', meaning: 'sol'),
        _VocabularyItem(term: 'tlalli', meaning: 'tierra'),
        _VocabularyItem(term: 'xochitl', meaning: 'flor'),
        _VocabularyItem(term: 'metztli', meaning: 'luna'),
        _VocabularyItem(term: 'tochtli', meaning: 'conejo'),
        _VocabularyItem(term: 'tepetl', meaning: 'cerro'),
        _VocabularyItem(term: 'piltontli', meaning: 'nino'),
        _VocabularyItem(term: 'cualli', meaning: 'bien'),
      ],
      stories: [
        _Story(
          nativeText:
              'In tochtli ihuan metztli. Ce yohual, ce tochtli quitac metztli. Metztli cenca pepetlaca. Tochtli quinequia tlecoz ipan tepetl.',
          spanishText:
              'El conejo y la luna. Una noche, un conejo miro a la luna. La luna brillaba mucho. El conejo queria subir al cerro.',
          question: 'Que vio el conejo?',
          answer: 'metztli',
          options: ['metztli', 'calli', 'atl', 'xochitl'],
        ),
        _Story(
          nativeText:
              'Xochitl ipan tlalli. Ce piltontli quitac xochitl ihuan quimocuitlahui. Momostla quitlalilia atl.',
          spanishText:
              'La flor en la tierra. Una nina vio una flor y la cuido. Cada dia le puso agua.',
          question: 'Que necesitaba la flor?',
          answer: 'atl',
          options: ['atl', 'tonatiuh', 'calli', 'tlalli'],
        ),
      ],
      dialogues: [
        _Dialogue(
          nativeText:
              'Piltontli: Pialli, quen tinemi?\nTemachtiani: Cualli, tlazohcamati.\nPiltontli: Notoca Ana.',
          spanishText:
              'Nina: Hola, como estas?\nMaestra: Bien, gracias.\nNina: Me llamo Ana.',
          question: 'Que significa "Pialli"?',
          answer: 'Hola',
          options: ['Hola', 'Agua', 'Casa', 'Flor'],
        ),
      ],
    ),
    'maya': _LanguageContent(
      alphabet: "a, b, ch, e, i, j, k, k', l, m, n, o, p, t, ts, u, x, y",
      basicSubject: 'Teen',
      basicVerb: 'in kaambal',
      words: [
        _VocabularyItem(term: "ja'", meaning: 'agua'),
        _VocabularyItem(term: 'kiin', meaning: 'sol'),
        _VocabularyItem(term: 'naj', meaning: 'casa'),
        _VocabularyItem(term: "xi'ik", meaning: 'ala'),
        _VocabularyItem(term: 'yaax', meaning: 'verde'),
        _VocabularyItem(term: 'uj', meaning: 'luna'),
        _VocabularyItem(term: "t'u'ul", meaning: 'conejo'),
        _VocabularyItem(term: 'luum', meaning: 'tierra'),
        _VocabularyItem(term: 'paal', meaning: 'nino'),
        _VocabularyItem(term: 'ma alob', meaning: 'bien'),
      ],
      stories: [
        _Story(
          nativeText:
              "Le t'u'ulo' yeetel le ujo'. Junp'eel ak'ab, junp'eel t'u'ul tu yilaj le ujo'. Le ujo' jach sasak'an.",
          spanishText:
              'El conejo y la luna. Una noche, un pequeno conejo vio la luna. La luna estaba muy brillante.',
          question: 'Que vio el conejo?',
          answer: "uj",
          options: ['uj', "ja'", 'naj', 'yaax'],
        ),
        _Story(
          nativeText:
              "Le naj ku yaantal tu lu'umil. Paal ku kanik u tsoolil naj, ja' yeetel kiin.",
          spanishText:
              'La casa esta en su tierra. Un nino aprende las partes de la casa, el agua y el sol.',
          question: 'Que palabra significa casa?',
          answer: 'naj',
          options: ['naj', "ja'", 'kiin', "xi'ik"],
        ),
      ],
      dialogues: [
        _Dialogue(
          nativeText:
              "Paal: Bix yanikech?\nXooknal: Ma'alob, kux teech?\nPaal: In kaba'e Ana.",
          spanishText:
              'Nino: Como estas?\nEstudiante: Bien, y tu?\nNino: Mi nombre es Ana.',
          question: 'Que pregunta sirve para saludar?',
          answer: 'Bix yanikech?',
          options: ['Bix yanikech?', 'In kabae Ana', 'naj', "ja'"],
        ),
      ],
    ),
    'purepecha': _LanguageContent(
      alphabet: 'a, ch, e, i, j, k, m, n, p, r, s, t, ts, u, x',
      basicSubject: 'Ji',
      basicVerb: 'janhaskani',
      words: [
        _VocabularyItem(term: 'ireta', meaning: 'pueblo'),
        _VocabularyItem(term: 'kurhucha', meaning: 'pez'),
        _VocabularyItem(term: 'tsitsiki', meaning: 'flor'),
        _VocabularyItem(term: 'uandani', meaning: 'hablar'),
        _VocabularyItem(term: 'juchari', meaning: 'nuestro'),
        _VocabularyItem(term: 'kutsi', meaning: 'luna'),
        _VocabularyItem(term: 'jurhiata', meaning: 'sol'),
        _VocabularyItem(term: 'sesi', meaning: 'bien'),
        _VocabularyItem(term: 'arhikua', meaning: 'nombre'),
        _VocabularyItem(term: 'ambakiti', meaning: 'bonito'),
      ],
      stories: [
        _Story(
          nativeText:
              'Kutsi ka kurhucha. Ma jurhiata, kurhucha kutsi sesi xarhati. Uandani jatsisti juchari ireta.',
          spanishText:
              'La luna y el pez. Un dia, el pez miro una luna bonita. Despues hablaron del pueblo.',
          question: 'Quien vio la luna?',
          answer: 'kurhucha',
          options: ['kurhucha', 'ireta', 'tsitsiki', 'juchari'],
        ),
      ],
      dialogues: [
        _Dialogue(
          nativeText:
              'Sesi, isku tu?\nSesi xan, eska neri arhikua?\nJi arhikua Ana.',
          spanishText:
              'Hola, como estas?\nBien, como te llamas?\nYo me llamo Ana.',
          question: 'Que respuesta dice un nombre?',
          answer: 'Ji arhikua Ana',
          options: ['Ji arhikua Ana', 'Sesi', 'kurhucha', 'ireta'],
        ),
      ],
    ),
    'mixteco': _LanguageContent(
      alphabet: 'a, ch, e, i, k, ku, n, nd, s, t, u, v, x, y',
      basicSubject: 'Yoo',
      basicVerb: 'kani',
      words: [
        _VocabularyItem(term: 'nuu', meaning: 'pueblo'),
        _VocabularyItem(term: 'yuku', meaning: 'cerro'),
        _VocabularyItem(term: 'ita', meaning: 'flor'),
        _VocabularyItem(term: 'ndute', meaning: 'agua'),
        _VocabularyItem(term: 'vehe', meaning: 'casa'),
        _VocabularyItem(term: 'yoo', meaning: 'luna'),
        _VocabularyItem(term: 'iso', meaning: 'conejo'),
        _VocabularyItem(term: 'kuaa', meaning: 'noche'),
        _VocabularyItem(term: 'nani', meaning: 'nombre'),
        _VocabularyItem(term: 'vaa', meaning: 'bien'),
      ],
      stories: [
        _Story(
          nativeText:
              'Iso ne yoo. In kuaa, iso ni jini yoo. Yoo vaa ni ndiko. Iso kuni tnuu yuku.',
          spanishText:
              'El conejo y la luna. Una noche, el conejo vio la luna. La luna brillaba bonito. El conejo quiso subir al cerro.',
          question: 'A donde queria subir el conejo?',
          answer: 'yuku',
          options: ['yuku', 'vehe', 'ita', 'ndute'],
        ),
      ],
      dialogues: [
        _Dialogue(
          nativeText:
              'Va a ni, ine yoo?\nVa a xan, nuu naniun?\nNani Ana, chuu ni yuku.',
          spanishText:
              'Hola, como estas?\nBien, como te llamas?\nMe llamo Ana, vengo del cerro.',
          question: 'Que palabra aparece como lugar?',
          answer: 'yuku',
          options: ['yuku', 'ita', 'ndute', 'vehe'],
        ),
      ],
    ),
    'otomi': _LanguageContent(
      alphabet: 'a, e, h, i, m, n, o, p, r, t, u, x, y, z',
      basicSubject: 'Nuga',
      basicVerb: 'di nxadi',
      words: [
        _VocabularyItem(term: 'hna', meaning: 'lengua'),
        _VocabularyItem(term: 'dehe', meaning: 'agua'),
        _VocabularyItem(term: 'ngu', meaning: 'casa'),
        _VocabularyItem(term: 'zi', meaning: 'pequeno'),
        _VocabularyItem(term: 'hyadi', meaning: 'sol'),
        _VocabularyItem(term: 'zana', meaning: 'luna'),
        _VocabularyItem(term: 'tsoni', meaning: 'nino'),
        _VocabularyItem(term: 'hno', meaning: 'bien'),
        _VocabularyItem(term: 'thuhu', meaning: 'nombre'),
        _VocabularyItem(term: 'ehe', meaning: 'venir'),
      ],
      stories: [
        _Story(
          nativeText:
              'Mxadi mana mhugi nua too. Ra tsoni bi handihu ra zana, ra dehe ne ra hyadi.',
          spanishText:
              'El aprendizaje del dia. El nino miro la luna, el agua y el sol.',
          question: 'Que palabra significa agua?',
          answer: 'dehe',
          options: ['dehe', 'ngu', 'hyadi', 'hna'],
        ),
      ],
      dialogues: [
        _Dialogue(
          nativeText: 'Ki hatsi?\nXa hno, nehe?\nDi thuhu Ana. Di ehe Toluca.',
          spanishText:
              'Como estas?\nEstoy bien, y tu?\nMe llamo Ana. Vengo de Toluca.',
          question: 'Que frase dice un nombre?',
          answer: 'Di thuhu Ana',
          options: ['Di thuhu Ana', 'Ki hatsi?', 'dehe', 'ngu'],
        ),
      ],
    ),
  };
}

class _LanguageContent {
  final String alphabet;
  final String basicSubject;
  final String basicVerb;
  final List<_VocabularyItem> words;
  final List<_Story> stories;
  final List<_Dialogue> dialogues;

  const _LanguageContent({
    required this.alphabet,
    required this.basicSubject,
    required this.basicVerb,
    required this.words,
    required this.stories,
    required this.dialogues,
  });

  factory _LanguageContent.fromFallback(List<String> words) {
    final vocabulary = words
        .map((word) => _VocabularyItem(term: word, meaning: 'palabra'))
        .toList();
    return _LanguageContent(
      alphabet: 'a, e, i, o, u',
      basicSubject: 'Yo',
      basicVerb: 'aprendo',
      words: vocabulary,
      stories: [
        _Story(
          nativeText: 'Una lectura corta con palabras del dialecto.',
          spanishText: 'Una lectura corta con palabras del dialecto.',
          question: 'Que aparece en la lectura?',
          answer: vocabulary.first.term,
          options: vocabulary.map((item) => item.term).take(4).toList(),
        ),
      ],
      dialogues: [
        const _Dialogue(
          nativeText: 'Hola. Como estas?',
          spanishText: 'Hola. Como estas?',
          question: 'Que tipo de texto es?',
          answer: 'saludo',
          options: ['saludo', 'cuento', 'numero', 'color'],
        ),
      ],
    );
  }
}

class _VocabularyItem {
  final String term;
  final String meaning;

  const _VocabularyItem({required this.term, required this.meaning});
}

class _Story {
  final String nativeText;
  final String spanishText;
  final String question;
  final String answer;
  final List<String> options;

  const _Story({
    required this.nativeText,
    required this.spanishText,
    required this.question,
    required this.answer,
    required this.options,
  });
}

class _Dialogue {
  final String nativeText;
  final String spanishText;
  final String question;
  final String answer;
  final List<String> options;

  const _Dialogue({
    required this.nativeText,
    required this.spanishText,
    required this.question,
    required this.answer,
    required this.options,
  });
}
