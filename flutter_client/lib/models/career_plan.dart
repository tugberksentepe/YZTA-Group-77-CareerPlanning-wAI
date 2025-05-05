/// Kariyer planı bilgilerini temsil eden sınıf
class CareerPlan {
  /// Planın içeriği (markdown formatında)
  final String planContent;
  
  /// Planın oluşturulma zamanı
  final DateTime createdAt;

  /// Yeni bir kariyer planı nesnesi oluşturur
  CareerPlan({
    required this.planContent,
    required this.createdAt,
  });

  /// API yanıtından bir CareerPlan nesnesi oluşturur
  factory CareerPlan.fromJson(Map<String, dynamic> json) {
    return CareerPlan(
      planContent: json['plan_content'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  /// CareerPlan nesnesini JSON formatına dönüştürür
  Map<String, dynamic> toJson() {
    return {
      'plan_content': planContent,
      'created_at': createdAt.toIso8601String(),
    };
  }
} 