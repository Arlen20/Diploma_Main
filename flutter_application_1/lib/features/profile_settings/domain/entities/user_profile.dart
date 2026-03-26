class UserProfile {
  final String uid;
  final String email;
  final String name;
  final String goal;
  final int heightCm;
  final int weightKg;
  final int age;
  final bool onboardingCompleted;

  const UserProfile({
    required this.uid,
    required this.email,
    required this.name,
    required this.goal,
    required this.heightCm,
    required this.weightKg,
    required this.age,
    required this.onboardingCompleted,
  });

  static const empty = UserProfile(
    uid: '',
    email: '',
    name: 'User',
    goal: 'Maintain',
    heightCm: 175,
    weightKg: 70,
    age: 20,
    onboardingCompleted: false,
  );

  UserProfile copyWith({
    String? uid,
    String? email,
    String? name,
    String? goal,
    int? heightCm,
    int? weightKg,
    int? age,
    bool? onboardingCompleted,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      goal: goal ?? this.goal,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      age: age ?? this.age,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'email': email,
        'name': name,
        'goal': goal,
        'heightCm': heightCm,
        'weightKg': weightKg,
        'age': age,
        'onboardingCompleted': onboardingCompleted,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] as String? ?? empty.uid,
      email: json['email'] as String? ?? empty.email,
      name: json['name'] as String? ?? empty.name,
      goal: json['goal'] as String? ?? empty.goal,
      heightCm: json['heightCm'] as int? ?? empty.heightCm,
      weightKg: json['weightKg'] as int? ?? empty.weightKg,
      age: json['age'] as int? ?? empty.age,
      onboardingCompleted:
          json['onboardingCompleted'] as bool? ?? empty.onboardingCompleted,
    );
  }
}
