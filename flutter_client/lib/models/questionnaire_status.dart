/// Anket tamamlama durumunu temsil eden sınıf
class QuestionnaireStatus {
  /// Anket tamamlandı mı?
  final bool isComplete;
  
  /// Toplam soru sayısı
  final int totalQuestions;
  
  /// Mevcut soru numarası (varsa)
  final int? currentQuestion;
  
  /// Sonraki soru metni (varsa)
  final String? nextQuestion;

  /// Yeni bir anket durumu nesnesi oluşturur
  QuestionnaireStatus({
    required this.isComplete,
    required this.totalQuestions,
    this.currentQuestion,
    this.nextQuestion,
  });

  /// API yanıtından bir QuestionnaireStatus nesnesi oluşturur
  factory QuestionnaireStatus.fromJson(Map<String, dynamic> json) {
    return QuestionnaireStatus(
      isComplete: json['is_complete'],
      totalQuestions: json['total_questions'],
      currentQuestion: json['current_question'],
      nextQuestion: json['next_question'],
    );
  }

  /// QuestionnaireStatus nesnesini JSON formatına dönüştürür
  Map<String, dynamic> toJson() {
    return {
      'is_complete': isComplete,
      'total_questions': totalQuestions,
      'current_question': currentQuestion,
      'next_question': nextQuestion,
    };
  }
} 