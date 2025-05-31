
class User {
  final int id; // Jika API mengembalikan ID
  final String name;
  final String email;
  final String role; // Jika API mengembalikan role

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  // Opsional: factory constructor jika Anda ingin membuat User dari Map secara langsung di tempat lain
  // factory User.fromJson(Map<String, dynamic> json) {
  //   return User(
  //     id: json['id'] ?? 0,
  //     name: json['name'] ?? 'Unknown User',
  //     email: json['email'] ?? '',
  //     role: json['role'] ?? 'user',
  //   );
  // }
}