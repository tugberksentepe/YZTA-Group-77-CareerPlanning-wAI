/// Konuşma mesajını temsil eden sınıf
class ConversationMessage {
  /// Mesaj içeriği
  final String message;
  
  /// Mesaj kullanıcıdan mı geldi?
  final bool isUser;
  
  /// Mesajın oluşturulma zamanı
  final DateTime createdAt;

  /// Yeni bir konuşma mesajı nesnesi oluşturur
  ConversationMessage({
    required this.message,
    required this.isUser,
    required this.createdAt,
  });

  /// API yanıtından bir ConversationMessage nesnesi oluşturur
  factory ConversationMessage.fromJson(Map<String, dynamic> json) {
    return ConversationMessage(
      message: json['message'],
      isUser: json['is_user'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  /// ConversationMessage nesnesini JSON formatına dönüştürür
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'is_user': isUser,
      'created_at': createdAt.toIso8601String(),
    };
  }
} 