/// API'den gelen başarılı yanıtları temsil eder
class SuccessResponse {
  /// İşlemin başarılı olup olmadığı
  final bool success;
  
  /// Başarı mesajı
  final String message;

  /// Yeni bir başarı yanıtı nesnesi oluşturur
  SuccessResponse({
    required this.success,
    required this.message,
  });

  /// API yanıtından bir SuccessResponse nesnesi oluşturur
  factory SuccessResponse.fromJson(Map<String, dynamic> json) {
    return SuccessResponse(
      success: json['success'],
      message: json['message'],
    );
  }
}

/// API'den gelen hata yanıtlarını temsil eder
class ErrorResponse {
  /// İşlemin başarılı olup olmadığı
  final bool success;
  
  /// Hata mesajı
  final String error;

  /// Yeni bir hata yanıtı nesnesi oluşturur
  ErrorResponse({
    required this.success,
    required this.error,
  });

  /// API yanıtından bir ErrorResponse nesnesi oluşturur
  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      success: json['success'],
      error: json['error'],
    );
  }
}

/// AI ile sohbet yanıtını temsil eder
class ChatResponse {
  /// AI'ın verdiği yanıt
  final String response;

  /// Yeni bir sohbet yanıtı nesnesi oluşturur
  ChatResponse({
    required this.response,
  });

  /// API yanıtından bir ChatResponse nesnesi oluşturur
  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      response: json['response'],
    );
  }
} 