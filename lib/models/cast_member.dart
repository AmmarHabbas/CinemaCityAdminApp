class CastMember {
  final String name;
  final String role;
  final String photoUrl;

  const CastMember({
    required this.name,
    required this.role,
    required this.photoUrl,
  });

  Map<String, dynamic> toMap() {
    return {'name': name, 'role': role, 'photoUrl': photoUrl};
  }

  factory CastMember.fromMap(Map<String, dynamic> map) {
    return CastMember(
      name: map['name'] ?? '',
      role: map['role'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
    );
  }
}
