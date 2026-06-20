class Membership {
  final int id;
  final String planName;
  final double planPrice;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final int daysRemaining;

  Membership({
    required this.id,
    required this.planName,
    required this.planPrice,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.daysRemaining,
  });

  factory Membership.fromJson(Map<String, dynamic> json) {
    return Membership(
      id: json['id'] as int,
      planName: json['planName'] as String,
      planPrice: (json['planPrice'] as num).toDouble(),
      status: json['status'] as String,
      // The API serializes DateOnly as "yyyy-MM-dd", which DateTime.parse handles directly.
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      daysRemaining: json['daysRemaining'] as int,
    );
  }
}
