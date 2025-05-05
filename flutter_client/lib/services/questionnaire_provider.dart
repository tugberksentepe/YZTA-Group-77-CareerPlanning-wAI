import 'package:flutter/foundation.dart';
import '../models/question.dart';
import '../models/questionnaire_status.dart';
import 'api_service.dart';

/// Anket durumunu ve işlemlerini yöneten provider sınıfı
class QuestionnaireProvider with ChangeNotifier {
  final ApiService _apiService;
  
  /// Anketin mevcut durumu
  QuestionnaireStatus? _status;
  
  /// Şu anki soru
  Question? _currentQuestion;
  
  /// Tüm yanıtlanmış soruların listesi
  List<Question> _answers = [];
  
  /// Veri yükleniyor mu?
  bool _isLoading = false;
  
  /// Hata mesajı (varsa)
  String? _errorMessage;
  
  /// Get metotları
  QuestionnaireStatus? get status => _status;
  Question? get currentQuestion => _currentQuestion;
  List<Question> get answers => _answers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isComplete => _status?.isComplete ?? false;

  /// Yeni bir questionnaire provider nesnesi oluşturur
  QuestionnaireProvider({required ApiService apiService}) : _apiService = apiService;

  /// Anket durumunu API'den getirir
  Future<void> checkStatus() async {
    _setLoading(true);
    try {
      _status = await _apiService.getQuestionnaireStatus();
      notifyListeners();
    } catch (e) {
      _setError('Anket durumu alınamadı: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Bir sonraki soruyu API'den getirir
  Future<void> getNextQuestion() async {
    _setLoading(true);
    try {
      _currentQuestion = await _apiService.getNextQuestion();
      notifyListeners();
    } catch (e) {
      _setError('Soru alınamadı: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Cevabı API'ye gönderir
  Future<void> submitAnswer(String answer) async {
    if (_currentQuestion == null) {
      _setError('Aktif soru bulunamadı');
      return;
    }

    _setLoading(true);
    try {
      await _apiService.submitAnswer(_currentQuestion!.questionNumber, answer);
      
      // Cevabı kaydediyoruz
      _currentQuestion!.answer = answer;
      _answers.add(_currentQuestion!);
      
      // Anket durumunu ve sonraki soruyu alıyoruz
      await checkStatus();
      
      if (_status != null && !_status!.isComplete) {
        await getNextQuestion();
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Cevap gönderilemedi: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Tüm cevapları API'den getirir
  Future<void> getAllAnswers() async {
    _setLoading(true);
    try {
      _answers = await _apiService.getAllAnswers();
      notifyListeners();
    } catch (e) {
      _setError('Cevaplar alınamadı: $e');
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