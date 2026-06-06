class UserProfile {
  final String uid;
  final String email;
  final String name;
  final String goal;
  final String sex;
  final String activityLevel;
  final int preferredTrainingDays;
  final int heightCm;
  final int weightKg;
  final int age;
  final bool onboardingCompleted;
  final String avatarLocalPath;

  const UserProfile({
    required this.uid,
    required this.email,
    required this.name,
    required this.goal,
    required this.sex,
    required this.activityLevel,
    required this.preferredTrainingDays,
    required this.heightCm,
    required this.weightKg,
    required this.age,
    required this.onboardingCompleted,
    required this.avatarLocalPath,
  });

  static const empty = UserProfile(
    uid: '',
    email: '',
    name: 'User',
    goal: 'Maintain',
    sex: 'Male',
    activityLevel: 'Moderate',
    preferredTrainingDays: 4,
    heightCm: 175,
    weightKg: 70,
    age: 20,
    onboardingCompleted: false,
    avatarLocalPath: '',
  );

  UserProfile copyWith({
    String? uid,
    String? email,
    String? name,
    String? goal,
    String? sex,
    String? activityLevel,
    int? preferredTrainingDays,
    int? heightCm,
    int? weightKg,
    int? age,
    bool? onboardingCompleted,
    String? avatarLocalPath,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      goal: goal ?? this.goal,
      sex: sex ?? this.sex,
      activityLevel: activityLevel ?? this.activityLevel,
      preferredTrainingDays:
          preferredTrainingDays ?? this.preferredTrainingDays,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      age: age ?? this.age,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      avatarLocalPath: avatarLocalPath ?? this.avatarLocalPath,
    );
  }

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'email': email,
    'name': name,
    'goal': goal,
    'sex': sex,
    'activityLevel': activityLevel,
    'preferredTrainingDays': preferredTrainingDays,
    'heightCm': heightCm,
    'weightKg': weightKg,
    'age': age,
    'onboardingCompleted': onboardingCompleted,
    'avatarLocalPath': avatarLocalPath,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] as String? ?? empty.uid,
      email: json['email'] as String? ?? empty.email,
      name: json['name'] as String? ?? empty.name,
      goal: json['goal'] as String? ?? empty.goal,
      sex: json['sex'] as String? ?? empty.sex,
      activityLevel: json['activityLevel'] as String? ?? empty.activityLevel,
      preferredTrainingDays:
          json['preferredTrainingDays'] as int? ?? empty.preferredTrainingDays,
      heightCm: json['heightCm'] as int? ?? empty.heightCm,
      weightKg: json['weightKg'] as int? ?? empty.weightKg,
      age: json['age'] as int? ?? empty.age,
      onboardingCompleted:
          json['onboardingCompleted'] as bool? ?? empty.onboardingCompleted,
      avatarLocalPath:
          json['avatarLocalPath'] as String? ?? empty.avatarLocalPath,
    );
  }
}
