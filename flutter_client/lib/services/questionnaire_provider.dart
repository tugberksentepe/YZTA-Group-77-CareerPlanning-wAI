import 'package:flutter/foundation.dart';
import '../models/question.dart';
import '../models/questionnaire_status.dart';
import 'api_service.dart';

class QuestionnaireProvider with ChangeNotifier {
  final ApiService _apiService;

  QuestionnaireStatus? _status;

  Question? _currentQuestion;

  List<Question> _answers = [];

  bool _isLoading = false;

  String? _errorMessage;

  QuestionnaireStatus? get status => _status;
  Question? get currentQuestion => _currentQuestion;
  List<Question> get answers => _answers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isComplete => _status?.isComplete ?? false;

  QuestionnaireProvider({required ApiService apiService}) : _apiService = apiService;

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

  Future<void> submitAnswer(String answer) async {
    if (_currentQuestion == null) {
      _setError('Aktif soru bulunamadı');
      return;
    }

    _setLoading(true);
    try {
      await _apiService.submitAnswer(_currentQuestion!.questionNumber, answer);

      _currentQuestion!.answer = answer;
      _answers.add(_currentQuestion!);

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