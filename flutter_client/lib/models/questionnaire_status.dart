class QuestionnaireStatus {
  final bool isComplete;

  final int totalQuestions;

  final int? currentQuestion;

  final String? nextQuestion;

  QuestionnaireStatus({
    required this.isComplete,
    required this.totalQuestions,
    this.currentQuestion,
    this.nextQuestion,
  });

  factory QuestionnaireStatus.fromJson(Map<String, dynamic> json) {
    return QuestionnaireStatus(
      isComplete: json['is_complete'],
      totalQuestions: json['total_questions'],
      currentQuestion: json['current_question'],
      nextQuestion: json['next_question'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_complete': isComplete,
      'total_questions': totalQuestions,
      'current_question': currentQuestion,
      'next_question': nextQuestion,
    };
  }
} 