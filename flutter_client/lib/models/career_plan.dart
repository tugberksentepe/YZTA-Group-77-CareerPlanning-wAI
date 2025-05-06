class CareerPlan {
  final String planContent;

  final DateTime createdAt;

  CareerPlan({
    required this.planContent,
    required this.createdAt,
  });

  factory CareerPlan.fromJson(Map<String, dynamic> json) {
    return CareerPlan(
      planContent: json['plan_content'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plan_content': planContent,
      'created_at': createdAt.toIso8601String(),
    };
  }
} 