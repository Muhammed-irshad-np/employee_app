class Employee {
  final int? id;
  final String name;
  final String role;
  final DateTime startDate;
  final DateTime? endDate;

  Employee({
    this.id,
    required this.name,
    required this.role,
    required this.startDate,
    this.endDate,
  });

  Employee copyWith({
    int? id,
    String? name,
    String? role,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return Employee(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
    };
  }

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'],
      name: map['name'],
      role: map['role'],
      startDate: DateTime.parse(map['startDate']),
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Employee &&
        other.id == id &&
        other.name == name &&
        other.role == role &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        role.hashCode ^
        startDate.hashCode ^
        endDate.hashCode;
  }
}
