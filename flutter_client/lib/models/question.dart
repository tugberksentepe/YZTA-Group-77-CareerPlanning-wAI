/// Anket sorusunu temsil eden sınıf
class Question {
  /// Sorunun metni
  final String question;
  
  /// Sorunun numarası (1-10 arası)
  final int questionNumber;
  
  /// Kullanıcının cevabı (varsa)
  String? answer;

  /// Yeni bir soru nesnesi oluşturur
  Question({
    required this.question,
    required this.questionNumber,
    this.answer,
  });

  /// API yanıtından bir Question nesnesi oluşturur
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question: json['question'],
      questionNumber: json['question_number'],
      answer: json['answer'],
    );
  }

  /// Question nesnesini JSON formatına dönüştürür
  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'question_number': questionNumber,
      'answer': answer,
    };
  }
} 