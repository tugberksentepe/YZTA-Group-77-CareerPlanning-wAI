import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/env.dart';
import '../models/question.dart';
import '../models/questionnaire_status.dart';
import '../models/career_plan.dart';
import '../models/api_response.dart';
import '../models/conversation_message.dart';


class ApiService {
  final String baseUrl;
  final String email;

  final http.Client client;

  ApiService({
    String? baseUrl,
    String? email,
    http.Client? client,
  }) : 
    baseUrl = baseUrl ?? EnvConfig.apiBaseUrl,
    email = email ?? EnvConfig.defaultEmail,
    client = client ?? http.Client();

  Future<QuestionnaireStatus> getQuestionnaireStatus() async {
    final response = await client.get(
      Uri.parse('$baseUrl/questionnaire/status?email=$email'),
    );

    if (response.statusCode == 200) {
      return QuestionnaireStatus.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Anket durumu alınamadı: ${response.body}');
    }
  }

  Future<Question> getNextQuestion() async {
    final response = await client.get(
      Uri.parse('$baseUrl/questionnaire/question?email=$email'),
    );

    if (response.statusCode == 200) {
      return Question.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Soru alınamadı: ${response.body}');
    }
  }

  Future<SuccessResponse> submitAnswer(int questionNumber, String answer) async {
    final response = await client.post(
      Uri.parse('$baseUrl/questionnaire/answer?email=$email&question_number=$questionNumber'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'answer': answer,
      }),
    );

    if (response.statusCode == 200) {
      return SuccessResponse.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Cevap gönderilemedi: ${response.body}');
    }
  }

  Future<List<Question>> getAllAnswers() async {
    final response = await client.get(
      Uri.parse('$baseUrl/questionnaire/answers?email=$email'),
    );

    if (response.statusCode == 200) {
      List<dynamic> answersJson = jsonDecode(utf8.decode(response.bodyBytes));
      return answersJson.map((json) => Question.fromJson(json)).toList();
    } else {
      throw Exception('Cevaplar alınamadı: ${response.body}');
    }
  }

  Future<SuccessResponse> generateCareerPlan() async {
    final response = await client.post(
      Uri.parse('$baseUrl/career-plan/generate?email=$email'),
    );

    if (response.statusCode == 200) {
      return SuccessResponse.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Kariyer planı oluşturulamadı: ${response.body}');
    }
  }

  Future<CareerPlan> getCareerPlan() async {
    final response = await client.get(
      Uri.parse('$baseUrl/career-plan/?email=$email'),
    );

    if (response.statusCode == 200) {
      return CareerPlan.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Kariyer planı alınamadı: ${response.body}');
    }
  }

  Future<ChatResponse> sendChatMessage(String message) async {
    final response = await client.post(
      Uri.parse('$baseUrl/career-plan/chat?email=$email'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'message': message,
      }),
    );

    if (response.statusCode == 200) {
      return ChatResponse.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Mesaj gönderilemedi: ${response.body}');
    }
  }

  Future<List<ConversationMessage>> getChatHistory({int limit = 10}) async {
    final response = await client.get(
      Uri.parse('$baseUrl/career-plan/chat-history?email=$email&limit=$limit'),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseJson = jsonDecode(utf8.decode(response.bodyBytes));
      List<dynamic> historyJson = responseJson['history'];
      return historyJson.map((json) => ConversationMessage.fromJson(json)).toList();
    } else {
      throw Exception('Sohbet geçmişi alınamadı: ${response.body}');
    }
  }
} 