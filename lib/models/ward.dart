class Ward {
  const Ward({required this.id, required this.name});

  final String id;
  final String name;

  factory Ward.fromJson(Map<String, dynamic> json) {
    return Ward(id: json['id'] as String, name: json['name'] as String);
  }
}
