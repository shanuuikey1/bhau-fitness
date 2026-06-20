class Plan {
  final int id;
  final String name;
  final double price;
  final int durationDays;
  final String? description;

  Plan({
    required this.id,
    required this.name,
    required this.price,
    required this.durationDays,
    this.description,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['id'] as int,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      durationDays: json['durationDays'] as int,
      description: json['description'] as String?,
    );
  }
}
