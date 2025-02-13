class Subject {
  final int id;
  final String name;
  final String track;
  final List<Teacher>? teachers;

  Subject({
    required this.id,
    required this.name,
    required this.track,
    this.teachers,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'],
      name: json['name'],
      track: json['track'],
      teachers: json['teachers'] != null
          ? List<Teacher>.from(
              (json['teachers'] as List).map((x) => Teacher.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'track': track,
      'teachers': teachers?.map((x) => x.toJson()).toList(),
    };
  }
}

class Teacher {
  final int id;
  final String name;

  Teacher({
    required this.id,
    required this.name,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
