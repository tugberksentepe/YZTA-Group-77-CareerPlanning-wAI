import 'package:flutter/foundation.dart';
import '../models/career_plan.dart';
import '../models/conversation_message.dart';
import 'api_service.dart';

class CareerPlanProvider with ChangeNotifier {
  final ApiService _apiService;

  CareerPlan? _careerPlan;

  List<ConversationMessage> _chatHistory = [];

  bool _isLoading = false;

  bool _isGenerating = false;

  bool _isSendingMessage = false;

  String? _errorMessage;

  CareerPlan? get careerPlan => _careerPlan;
  List<ConversationMessage> get chatHistory => _chatHistory;
  bool get isLoading => _isLoading;
  bool get isGenerating => _isGenerating;
  bool get isSendingMessage => _isSendingMessage;
  String? get errorMessage => _errorMessage;
  bool get hasPlan => _careerPlan != null;

  CareerPlanProvider({required ApiService apiService}) : _apiService = apiService;

  Future<void> loadData() async {
    _setLoading(true);
    try {
      _careerPlan = await _apiService.getCareerPlan();

      _chatHistory = await _apiService.getChatHistory();
      
      notifyListeners();
    } catch (e) {
      _setError('Veriler alınamadı: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> generateCareerPlan() async {
    _isGenerating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.generateCareerPlan();

      _careerPlan = await _apiService.getCareerPlan();
      
      notifyListeners();
    } catch (e) {
      _setError('Kariyer planı oluşturulamadı: $e');
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    _isSendingMessage = true;

    _chatHistory.add(
      ConversationMessage(
        message: message,
        isUser: true,
        createdAt: DateTime.now(),
      ),
    );
    
    notifyListeners();

    try {
      final response = await _apiService.sendChatMessage(message);

      _chatHistory.add(
        ConversationMessage(
          message: response.response,
          isUser: false,
          createdAt: DateTime.now(),
        ),
      );
      
      notifyListeners();
    } catch (e) {
      _setError('Mesaj gönderilemedi: $e');
    } finally {
      _isSendingMessage = false;
      notifyListeners();
    }
  }

  Future<void> loadChatHistory({int limit = 10}) async {
    _setLoading(true);
    try {
      _chatHistory = await _apiService.getChatHistory(limit: limit);
      notifyListeners();
    } catch (e) {
      _setError('Sohbet geçmişi alınamadı: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
} 