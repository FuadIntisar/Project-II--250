class Course {
  final String id;
  final String name;
  final String code;

  Course({required this.id, required this.name, required this.code});

  factory Course.fromMap(String id, Map<String, dynamic> map) {
    return Course(
      id: id,
      name: map['name'] ?? '',
      code: map['code'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {'name': name, 'code': code};
}

class Student {
  final String id;
  final String name;
  final String roll;

  Student({required this.id, required this.name, required this.roll});

  factory Student.fromMap(String id, Map<String, dynamic> map) {
    return Student(
      id: id,
      name: map['name'] ?? '',
      roll: map['roll'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {'name': name, 'roll': roll};
}
