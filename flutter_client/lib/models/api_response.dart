class SuccessResponse {
  final bool success;

  final String message;

  SuccessResponse({
    required this.success,
    required this.message,
  });

  factory SuccessResponse.fromJson(Map<String, dynamic> json) {
    return SuccessResponse(
      success: json['success'],
      message: json['message'],
    );
  }
}

class ErrorResponse {

  final bool success;

  final String error;

  ErrorResponse({
    required this.success,
    required this.error,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      success: json['success'],
      error: json['error'],
    );
  }
}

class ChatResponse {
  final String response;

  ChatResponse({
    required this.response,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      response: json['response'],
    );
  }
} 