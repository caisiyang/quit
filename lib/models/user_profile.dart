class UserProfile {
  String nickname;
  String? avatarPath;
  int smokingYears;
  int dailyCigarettes;

  UserProfile({
    this.nickname = '用户',
    this.avatarPath,
    this.smokingYears = 0,
    this.dailyCigarettes = 0,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      nickname: json['nickname'] ?? '用户',
      avatarPath: json['avatarPath'],
      smokingYears: json['smokingYears'] ?? 0,
      dailyCigarettes: json['dailyCigarettes'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nickname': nickname,
      'avatarPath': avatarPath,
      'smokingYears': smokingYears,
      'dailyCigarettes': dailyCigarettes,
    };
  }
}
