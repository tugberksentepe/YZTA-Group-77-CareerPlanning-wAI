import 'package:flutter/foundation.dart';
import '../models/career_plan.dart';
import '../models/conversation_message.dart';
import 'api_service.dart';

/// Kariyer planı ve sohbet işlemlerini yöneten provider sınıfı
class CareerPlanProvider with ChangeNotifier {
  final ApiService _apiService;
  
  /// Kariyer planı
  CareerPlan? _careerPlan;
  
  /// Sohbet geçmişi
  List<ConversationMessage> _chatHistory = [];
  
  /// Veri yükleniyor mu?
  bool _isLoading = false;
  
  /// Plan oluşturuluyor mu?
  bool _isGenerating = false;
  
  /// Mesaj gönderiliyor mu?
  bool _isSendingMessage = false;
  
  /// Hata mesajı (varsa)
  String? _errorMessage;
  
  /// Get metotları
  CareerPlan? get careerPlan => _careerPlan;
  List<ConversationMessage> get chatHistory => _chatHistory;
  bool get isLoading => _isLoading;
  bool get isGenerating => _isGenerating;
  bool get isSendingMessage => _isSendingMessage;
  String? get errorMessage => _errorMessage;
  bool get hasPlan => _careerPlan != null;

  /// Yeni bir career plan provider nesnesi oluşturur
  CareerPlanProvider({required ApiService apiService}) : _apiService = apiService;

  /// Kariyer planı ve sohbet geçmişini yükler
  Future<void> loadData() async {
    _setLoading(true);
    try {
      // Kariyer planını al
      _careerPlan = await _apiService.getCareerPlan();
      
      // Sohbet geçmişini al
      _chatHistory = await _apiService.getChatHistory();
      
      notifyListeners();
    } catch (e) {
      _setError('Veriler alınamadı: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Kariyer planı oluşturur
  Future<void> generateCareerPlan() async {
    _isGenerating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Kariyer planı oluşturma isteği gönder
      await _apiService.generateCareerPlan();
      
      // Oluşan planı yükle
      _careerPlan = await _apiService.getCareerPlan();
      
      notifyListeners();
    } catch (e) {
      _setError('Kariyer planı oluşturulamadı: $e');
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  /// Sohbet mesajı gönderir
  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    _isSendingMessage = true;
    
    // Kullanıcı mesajını ekle
    _chatHistory.add(
      ConversationMessage(
        message: message,
        isUser: true,
        createdAt: DateTime.now(),
      ),
    );
    
    notifyListeners();

    try {
      // Mesajı API'ye gönder
      final response = await _apiService.sendChatMessage(message);
      
      // AI yanıtını ekle
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

  /// Sohbet geçmişini yükler
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

  /// Yükleme durumunu ayarlar
  void _setLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  /// Hata mesajını ayarlar
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Hata mesajını temizler
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
} 