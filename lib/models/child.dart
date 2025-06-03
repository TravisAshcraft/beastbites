class Child {
  final int? id;      // will be null before inserted into the database
  final String name;  // child’s name
  // You can add more fields later, e.g. PIN, avatarUri, etc.

  Child({this.id, required this.name});

  /// Convert a Child into a Map<String, dynamic> for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  /// Create a Child from a SQLite row.
  factory Child.fromMap(Map<String, dynamic> map) {
    return Child(
      id: map['id'] as int?,
      name: map['name'] as String,
    );
  }

  /// Create a copy with a new id or name
  Child copyWith({int? id, String? name}) {
    return Child(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}
