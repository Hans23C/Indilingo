import 'package:flutter/material.dart';

import 'ai_assistant_api.dart';
import 'course_data.dart';

class AiAssistantScreen extends StatefulWidget {
  final List<CourseLanguage> languages;

  const AiAssistantScreen({super.key, required this.languages});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final AiAssistantApi _api = AiAssistantApi();
  final TextEditingController _questionController = TextEditingController();
  final List<_ChatMessage> _messages = [
    const _ChatMessage(
      fromUser: false,
      text:
          'Hola. Soy tu asistente inteligente. Puedo ayudarte con cualquier pregunta y tambien con tus dialectos.',
    ),
  ];
  late CourseLanguage _selectedLanguage = widget.languages.first;
  bool _isLoading = false;

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _sendQuestion() async {
    final question = _questionController.text.trim();
    if (question.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(_ChatMessage(fromUser: true, text: question));
      _questionController.clear();
      _isLoading = true;
    });

    final answer = await _api.ask(
      languageName: _selectedLanguage.name,
      question: question,
    );

    if (!mounted) return;
    setState(() {
      _messages.add(_ChatMessage(fromUser: false, text: answer));
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Asistente inteligente')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: DropdownButtonFormField<CourseLanguage>(
                initialValue: _selectedLanguage,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  prefixIcon: const Icon(Icons.language),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                items: widget.languages.map((language) {
                  return DropdownMenuItem(
                    value: language,
                    child: Text(language.name),
                  );
                }).toList(),
                onChanged: (language) {
                  if (language != null) {
                    setState(() => _selectedLanguage = language);
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: _ConnectionStatus(connected: AiAssistantApi.isConfigured),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_isLoading && index == _messages.length) {
                    return const _TypingBubble();
                  }
                  return _MessageBubble(
                    message: _messages[index],
                    color: _selectedLanguage.color,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _questionController,
                      minLines: 1,
                      maxLines: 3,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendQuestion(),
                      decoration: InputDecoration(
                        hintText: 'Pregunta lo que necesites',
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _sendQuestion,
                    icon: const Icon(Icons.send_rounded),
                    tooltip: 'Enviar',
                    style: IconButton.styleFrom(
                      backgroundColor: _selectedLanguage.color,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectionStatus extends StatelessWidget {
  final bool connected;

  const _ConnectionStatus({required this.connected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: connected ? const Color(0xFFE0F4DD) : const Color(0xFFFFF6C5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            connected ? Icons.cloud_done_outlined : Icons.info_outline,
            size: 20,
            color: const Color(0xFF134343),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              connected
                  ? 'Conectado con OpenAI para responder preguntas completas.'
                  : 'Asistente en modo basico. Configura OPENAI_API_KEY al iniciar la app.',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final bool fromUser;
  final String text;

  const _ChatMessage({required this.fromUser, required this.text});
}

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;
  final Color color;

  const _MessageBubble({required this.message, required this.color});

  @override
  Widget build(BuildContext context) {
    final alignment = message.fromUser
        ? Alignment.centerRight
        : Alignment.centerLeft;
    final background = message.fromUser ? color : const Color(0xFFFFF6C5);
    final foreground = message.fromUser ? Colors.white : Colors.black87;

    return Align(
      alignment: alignment,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 330),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.text,
          style: TextStyle(color: foreground, height: 1.3),
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF6C5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text('Pensando...'),
      ),
    );
  }
}
