class UserModel {
  final int id;
  final String? name;
  final String email;
  final String role;
  final String? className;
  final String? rollNumber;
  final String? section;
  final String? masterProgram;
  final String? track;
  final String? phoneNumber;

  const UserModel({
    required this.id,
    this.name,
    required this.email,
    required this.role,
    this.className,
    this.rollNumber,
    this.section,
    this.masterProgram,
    this.track,
    this.phoneNumber,
  });

  // Getters pour prénom et nom
  String get firstName => name?.split(' ').first ?? email.split('@').first;
  String get lastName {
    if (name == null) return '';
    final parts = name!.split(' ');
    return parts.length > 1 ? parts.last : '';
  }

  String get initials {
    if (name != null && name!.isNotEmpty) {
      return '${name![0]}${lastName.isNotEmpty ? lastName[0] : ""}';
    }
    return email[0].toUpperCase();
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String?,
      email: json['email'] as String,
      // Par défaut, on considère l'utilisateur comme étudiant si aucun rôle n'est spécifié
      role: json['role'] as String? ?? 'student',
      className: json['className'] as String?,
      rollNumber: json['rollNumber'] as String?,
      section: json['section'] as String?,
      masterProgram: json['masterProgram'] as String?,
      track: json['track'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'className': className,
      'rollNumber': rollNumber,
      'section': section,
      'masterProgram': masterProgram,
      'track': track,
      'phoneNumber': phoneNumber,
    };
  }

  // Opérateur pour accéder aux propriétés comme un Map
  dynamic operator [](String key) {
    switch (key) {
      case 'id':
        return id;
      case 'name':
        return name;
      case 'email':
        return email;
      case 'role':
        return role;
      case 'className':
        return className;
      case 'rollNumber':
        return rollNumber;
      case 'section':
        return section;
      case 'masterProgram':
        return masterProgram;
      case 'track':
        return track;
      case 'phoneNumber':
        return phoneNumber;
      case 'firstName':
        return firstName;
      case 'lastName':
        return lastName;
      case 'initials':
        return initials;
      default:
        throw ArgumentError('Property $key not found in UserModel');
    }
  }

  // Pour comparer deux instances de UserModel
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.role == role &&
        other.className == className &&
        other.rollNumber == rollNumber &&
        other.section == section &&
        other.masterProgram == masterProgram &&
        other.track == track &&
        other.phoneNumber == phoneNumber;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      email,
      role,
      className,
      rollNumber,
      section,
      masterProgram,
      track,
      phoneNumber,
    );
  }

  // Pour faciliter le débogage
  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, role: $role, '
        'className: $className, rollNumber: $rollNumber, section: $section, '
        'masterProgram: $masterProgram, track: $track, phoneNumber: $phoneNumber)';
  }
}
