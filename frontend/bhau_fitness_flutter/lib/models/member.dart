class Member {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String goal;
  final String memberCode;
  final String role;

  Member({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.goal,
    required this.memberCode,
    this.role = 'Member',
  });

  bool get isAdmin => role == 'Admin';

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      goal: json['goal'] as String,
      memberCode: json['memberCode'] as String,
      role: json['role'] as String? ?? 'Member',
    );
  }
}
