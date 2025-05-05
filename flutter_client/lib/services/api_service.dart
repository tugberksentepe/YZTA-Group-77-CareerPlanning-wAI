import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/env.dart';
import '../models/question.dart';
import '../models/questionnaire_status.dart';
import '../models/career_plan.dart';
import '../models/api_response.dart';
import '../models/conversation_message.dart';

/// API ile iletişim kuran servis sınıfı
class ApiService {
  final String baseUrl;
  final String email;
  
  /// HTTP istemcisi
  final http.Client client;

  /// API servisinin yapılandırılması
  ApiService({
    String? baseUrl,
    String? email,
    http.Client? client,
  }) : 
    baseUrl = baseUrl ?? EnvConfig.apiBaseUrl,
    email = email ?? EnvConfig.defaultEmail,
    client = client ?? http.Client();

  /// API'den anket durumunu getirir
  Future<QuestionnaireStatus> getQuestionnaireStatus() async {
    final response = await client.get(
      Uri.parse('$baseUrl/questionnaire/status?email=$email'),
    );

    if (response.statusCode == 200) {
      return QuestionnaireStatus.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Anket durumu alınamadı: ${response.body}');
    }
  }

  /// API'den bir sonraki soruyu getirir
  Future<Question> getNextQuestion() async {
    final response = await client.get(
      Uri.parse('$baseUrl/questionnaire/question?email=$email'),
    );

    if (response.statusCode == 200) {
      return Question.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Soru alınamadı: ${response.body}');
    }
  }

  /// Cevabı API'ye gönderir
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
      return SuccessResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Cevap gönderilemedi: ${response.body}');
    }
  }

  /// Tüm cevapları API'den getirir
  Future<List<Question>> getAllAnswers() async {
    final response = await client.get(
      Uri.parse('$baseUrl/questionnaire/answers?email=$email'),
    );

    if (response.statusCode == 200) {
      List<dynamic> answersJson = jsonDecode(response.body);
      return answersJson.map((json) => Question.fromJson(json)).toList();
    } else {
      throw Exception('Cevaplar alınamadı: ${response.body}');
    }
  }

  /// Kariyer planı oluşturma isteği gönderir
  Future<SuccessResponse> generateCareerPlan() async {
    final response = await client.post(
      Uri.parse('$baseUrl/career-plan/generate?email=$email'),
    );

    if (response.statusCode == 200) {
      return SuccessResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Kariyer planı oluşturulamadı: ${response.body}');
    }
  }

  /// Kariyer planını API'den getirir
  Future<CareerPlan> getCareerPlan() async {
    final response = await client.get(
      Uri.parse('$baseUrl/career-plan/?email=$email'),
    );

    if (response.statusCode == 200) {
      return CareerPlan.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Kariyer planı alınamadı: ${response.body}');
    }
  }

  /// AI ile sohbet mesajı gönderir
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
      return ChatResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Mesaj gönderilemedi: ${response.body}');
    }
  }

  /// Sohbet geçmişini API'den getirir
  Future<List<ConversationMessage>> getChatHistory({int limit = 10}) async {
    final response = await client.get(
      Uri.parse('$baseUrl/career-plan/chat-history?email=$email&limit=$limit'),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseJson = jsonDecode(response.body);
      List<dynamic> historyJson = responseJson['history'];
      return historyJson.map((json) => ConversationMessage.fromJson(json)).toList();
    } else {
      throw Exception('Sohbet geçmişi alınamadı: ${response.body}');
    }
  }
} 