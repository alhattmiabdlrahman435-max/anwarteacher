class Student {
  final String id;
  final String name;
  final String classId;
  final List<String> subjectIds;

  const Student({
    required this.id,
    required this.name,
    required this.classId,
    required this.subjectIds,
  });

  Student copyWith({
    String? id,
    String? name,
    String? classId,
    List<String>? subjectIds,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      classId: classId ?? this.classId,
      subjectIds: subjectIds ?? this.subjectIds,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'classId': classId,
      'subjectIds': subjectIds,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      classId: map['classId'] ?? '',
      subjectIds: List<String>.from(map['subjectIds'] ?? []),
    );
  }
}
