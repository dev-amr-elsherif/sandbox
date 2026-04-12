enum UserRole { developer, owner, unknown }

class UserModel {
  final String uid; // المعرف الفريد للمستخدم من Firebase
  final String email; // البريد الإلكتروني
  final String name; // اسم المستخدم
  final String? photoUrl; // رابط الصورة الشخصية
  final String role; // دور المستخدم (developer أو owner)
  final List<String> skills; // قائمة المهارات (للمطورين)
  
  // New Portfolio Features
  final String? githubUrl;
  final String? aiBio;
  final String? githubSeniority;
  final List<String>? topAiSkills;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.photoUrl,
    required this.role,
    this.skills = const [],
    this.githubUrl,
    this.aiBio,
    this.githubSeniority,
    this.topAiSkills,
  });

  // تحويل البيانات الجاية من Firebase (Map) إلى كائن (Object) - مريح جداً للتعامل مع البيانات
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      photoUrl: map['photoUrl'],
      role: map['role'] ?? 'developer',
      skills: List<String>.from(map['skills'] ?? []),
      githubUrl: map['githubUrl'],
      aiBio: map['aiBio'],
      githubSeniority: map['githubSeniority'],
      topAiSkills: map['topAiSkills'] != null ? List<String>.from(map['topAiSkills']) : null,
    );
  }

  // تحويل الكائن إلى Map عشان نخزنه في Firebase
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'role': role,
      'skills': skills,
      'githubUrl': githubUrl,
      'aiBio': aiBio,
      'githubSeniority': githubSeniority,
      'topAiSkills': topAiSkills,
    };
  }
}
