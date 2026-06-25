class Teacher {
  final String id;
  final String name;
  final List<String> classIds;
  final List<String> subjectIds;

  const Teacher({
    required this.id,
    required this.name,
    required this.classIds,
    required this.subjectIds,
  });

  Teacher copyWith({
    String? id,
    String? name,
    List<String>? classIds,
    List<String>? subjectIds,
  }) {
    return Teacher(
      id: id ?? this.id,
      name: name ?? this.name,
      classIds: classIds ?? this.classIds,
      subjectIds: subjectIds ?? this.subjectIds,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'classIds': classIds,
      'subjectIds': subjectIds,
    };
  }

  factory Teacher.fromMap(Map<String, dynamic> map) {
    return Teacher(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      classIds: List<String>.from(map['classIds'] ?? []),
      subjectIds: List<String>.from(map['subjectIds'] ?? []),
    );
  }
}
