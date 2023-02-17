import 'dart:developer';

import '../backend/backend.dart';
import '../flutter_flow/flutter_flow_theme.dart';
import '../flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/question_answer.dart';
import 'chat_a_i_model.dart';
export 'chat_a_i_model.dart';
import 'package:mindfullness/chat_gpt_flutter.dart';

class ChatAIWidget extends StatefulWidget {
  const ChatAIWidget({Key? key}) : super(key: key);

  @override
  _ChatAIWidgetState createState() => _ChatAIWidgetState();
}

// const apiKey = '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';
// const apiKey = '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';
const apiKey = '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';

class _ChatAIWidgetState extends State<ChatAIWidget> {
  late ChatAIModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _unfocusNode = FocusNode();

  String? answer;
  final chatGpt = ChatGpt(apiKey: apiKey);
  bool loading = false;
  final testPrompt =
      'Which Disney character famously leaves a glass slipper behind at a royal ball?';

  final List<QuestionAnswer> questionAnswers = [];

  late TextEditingController textEditingController;

  StreamSubscription<CompletionResponse>? streamSubscription;

  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController();
    _model = createModel(context, () => ChatAIModel());
  }

  @override
  void dispose() {
    _model.dispose();

    textEditingController.dispose();
    streamSubscription?.cancel();
    _unfocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ChatGPT")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: ListView.separated(
                  itemCount: questionAnswers.length,
                  itemBuilder: (context, index) {
                    final questionAnswer = questionAnswers[index];
                    final answer = questionAnswer.answer.toString().trim();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SelectableText('You: ${questionAnswer.question}'),
                        const SizedBox(height: 12),
                        if (answer.isEmpty && loading)
                          const Center(child: CircularProgressIndicator())
                        else
                          SelectableText('chatAI: $answer'),
                      ],
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: textEditingController,
                      decoration: const InputDecoration(hintText: 'Type in...'),
                      onFieldSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ClipOval(
                    child: Material(
                      color: Colors.blue, // Button color
                      child: InkWell(
                        onTap: _sendMessage,
                        child: const SizedBox(
                          width: 48,
                          height: 48,
                          child: Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _sendMessage() async {
    final question = '${textEditingController.text}';
    setState(() {
      textEditingController.clear();
      loading = true;
      questionAnswers.add(
        QuestionAnswer(
          question: question,
          answer: StringBuffer(),
        ),
      );
    });
    final testRequest = CompletionRequest(
      prompt: [
        // 'i want you to act a psychologist. i will provide you my thoughts. i want you to give me scientific suggestions that will make me feel better. my first thought, $question'
        question,
      ],
      stream: true,
      maxTokens: 4000,
    );
    await _streamResponse(testRequest);
    setState(() => loading = false);
  }

  _streamResponse(CompletionRequest request) async {
    streamSubscription?.cancel();
    try {
      final stream = await chatGpt.createCompletionStream(request);
      streamSubscription = stream?.listen(
        (event) => setState(
          () {
            if (event.streamMessageEnd) {
              streamSubscription?.cancel();
            } else {
              return questionAnswers.last.answer.write(
                event.choices?.first.text,
              );
            }
          },
        ),
      );
    } catch (error) {
      setState(() {
        loading = false;
        questionAnswers.last.answer.write("Error");
      });
      log("Error occurred: $error");
    }
  }
}
