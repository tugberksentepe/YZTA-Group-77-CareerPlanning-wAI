class ConversationMessage {
  final String message;

  final bool isUser;

  final DateTime createdAt;

  ConversationMessage({
    required this.message,
    required this.isUser,
    required this.createdAt,
  });

  factory ConversationMessage.fromJson(Map<String, dynamic> json) {
    bool isUserBool;
    if (json['is_user'] is int) {
      isUserBool = json['is_user'] == 1;
    } else {
      isUserBool = json['is_user'] as bool;
    }
    
    return ConversationMessage(
      message: json['message'],
      isUser: isUserBool,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'is_user': isUser,
      'created_at': createdAt.toIso8601String(),
    };
  }
} 