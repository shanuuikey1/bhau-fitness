class PlanDistribution {
  final String planName;
  final int memberCount;
  PlanDistribution({required this.planName, required this.memberCount});

  factory PlanDistribution.fromJson(Map<String, dynamic> json) => PlanDistribution(
        planName: json['planName'] as String,
        memberCount: json['memberCount'] as int,
      );
}

class AdminMemberSummary {
  final String id;
  final String fullName;
  final String email;
  final String memberCode;
  final String? planName;
  final String? membershipStatus;
  final DateTime createdAt;

  AdminMemberSummary({
    required this.id,
    required this.fullName,
    required this.email,
    required this.memberCode,
    this.planName,
    this.membershipStatus,
    required this.createdAt,
  });

  factory AdminMemberSummary.fromJson(Map<String, dynamic> json) => AdminMemberSummary(
        id: json['id'] as String,
        fullName: json['fullName'] as String,
        email: json['email'] as String,
        memberCode: json['memberCode'] as String,
        planName: json['planName'] as String?,
        membershipStatus: json['membershipStatus'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class AdminOverview {
  final int totalMembers;
  final int activeMemberships;
  final double monthlyRecurringRevenue;
  final int activeClasses;
  final List<AdminMemberSummary> recentSignups;
  final List<PlanDistribution> planDistribution;

  AdminOverview({
    required this.totalMembers,
    required this.activeMemberships,
    required this.monthlyRecurringRevenue,
    required this.activeClasses,
    required this.recentSignups,
    required this.planDistribution,
  });

  factory AdminOverview.fromJson(Map<String, dynamic> json) => AdminOverview(
        totalMembers: json['totalMembers'] as int,
        activeMemberships: json['activeMemberships'] as int,
        monthlyRecurringRevenue: (json['monthlyRecurringRevenue'] as num).toDouble(),
        activeClasses: json['activeClasses'] as int,
        recentSignups: (json['recentSignups'] as List<dynamic>)
            .map((s) => AdminMemberSummary.fromJson(s as Map<String, dynamic>))
            .toList(),
        planDistribution: (json['planDistribution'] as List<dynamic>)
            .map((p) => PlanDistribution.fromJson(p as Map<String, dynamic>))
            .toList(),
      );
}
