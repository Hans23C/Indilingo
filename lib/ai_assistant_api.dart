import 'dart:convert';

import 'package:http/http.dart' as http;

class AiAssistantApi {
  AiAssistantApi({http.Client? client}) : _client = client ?? http.Client();

  static const _apiKey = String.fromEnvironment('OPENAI_API_KEY');
  static const _model = String.fromEnvironment(
    'OPENAI_MODEL',
    defaultValue: 'gpt-5.5',
  );

  static bool get isConfigured => _apiKey.isNotEmpty;

  final http.Client _client;

  Future<String> ask({
    required String languageName,
    required String question,
  }) async {
    if (_apiKey.isEmpty) {
      return _localAnswer(languageName, question);
    }

    late final http.Response response;
    try {
      response = await _client.post(
        Uri.parse('https://api.openai.com/v1/responses'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'instructions':
              'Eres un asistente inteligente general dentro de una app educativa para ninos de primaria. Puedes responder cualquier tipo de pregunta en espanol claro, amable y seguro. Cuando la pregunta trate de Nahuatl, Maya, Purepecha, Mixteco u Otomi, ayuda con lectura, escritura, gramatica, cultura y ejemplos sencillos. Si no estas seguro de una traduccion indigena, dilo con honestidad y recomienda validarla con una persona hablante o docente.',
          'input':
              'Contexto de la app: el estudiante esta aprendiendo $languageName, pero puede preguntar cualquier tema.\nPregunta: $question',
        }),
      );
    } catch (_) {
      return _localAnswer(languageName, question);
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return 'No pude conectar con OpenAI. Revisa que tu API Key sea correcta y que tenga credito o permisos activos. Codigo: ${response.statusCode}.';
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final outputText = data['output_text'];
    if (outputText is String && outputText.trim().isNotEmpty) {
      return outputText.trim();
    }

    final output = data['output'];
    if (output is List) {
      final buffer = StringBuffer();
      for (final item in output) {
        if (item is Map<String, dynamic>) {
          final content = item['content'];
          if (content is List) {
            for (final block in content) {
              if (block is Map<String, dynamic> && block['text'] is String) {
                buffer.write(block['text']);
              }
            }
          }
        }
      }
      final text = buffer.toString().trim();
      if (text.isNotEmpty) return text;
    }

    return 'Recibi respuesta, pero no pude leer el texto. Intenta preguntar de otra forma.';
  }

  String _localAnswer(String languageName, String question) {
    final lower = question.toLowerCase();
    if (lower.contains('hola') || lower.contains('buen')) {
      return 'Hola. Puedo ayudarte con tareas, dudas generales y tambien con $languageName. Preguntame lo que necesites.';
    }
    if (lower.contains('matematica') ||
        lower.contains('suma') ||
        lower.contains('resta')) {
      return 'Claro. Para matematicas, escribe el ejercicio completo y te explico paso a paso como resolverlo.';
    }
    if (lower.contains('historia') || lower.contains('ciencia')) {
      return 'Puedo ayudarte con esa materia. Hazme una pregunta concreta y te respondere con una explicacion corta y facil.';
    }
    if (lower.contains('abecedario') || lower.contains('letra')) {
      return 'Para practicar $languageName, empieza por mirar las letras que se repiten. Luego di la palabra en voz baja, tapala y escribela otra vez.';
    }
    if (lower.contains('cuento') || lower.contains('lectura')) {
      return 'Lee primero el texto en $languageName. Despues mira la traduccion en espanol y busca personajes, lugares y acciones.';
    }
    if (lower.contains('gramatica') || lower.contains('frase')) {
      return 'Para ordenar una frase, busca primero quien habla, luego la accion y al final la palabra clave.';
    }
    return 'Puedo ayudarte con cualquier pregunta. Si tienes conexion con la API configurada, respondere con mas detalle. Por ahora puedo orientarte: escribe una duda de escuela, lectura, escritura, gramatica o sobre $languageName.';
  }
}
