class Question {
  final String question;

  final int questionNumber;

  String? answer;

  Question({
    required this.question,
    required this.questionNumber,
    this.answer,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question: json['question'],
      questionNumber: json['question_number'],
      answer: json['answer'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'question_number': questionNumber,
      'answer': answer,
    };
  }
} 