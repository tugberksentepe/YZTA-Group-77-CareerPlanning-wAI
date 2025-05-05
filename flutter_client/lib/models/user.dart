/// Kullanıcı bilgilerini temsil eden sınıf
class User {
  /// Kullanıcının benzersiz kimliği
  final int id;
  
  /// Kullanıcının e-posta adresi
  final String email;
  
  /// Kullanıcının oluşturulma zamanı
  final DateTime createdAt;

  /// Yeni bir kullanıcı örneği oluşturur
  User({
    required this.id, 
    required this.email, 
    required this.createdAt
  });

  /// JSON verilerinden bir User nesnesi oluşturur
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  /// User nesnesini JSON formatına dönüştürür
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'created_at': createdAt.toIso8601String(),
    };
  }
} 