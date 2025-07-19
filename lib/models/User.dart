class User {
  final int id;
  final String role;
  final String nama;
  final String alamat;
  final String noHp;
  final String email;
  final bool status;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.role,
    required this.nama,
    required this.alamat,
    required this.noHp,
    required this.email,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      role: json['role'],
      nama: json['nama'],
      alamat: json['alamat'],
      noHp: json['no_hp'],
      email: json['email'],
      status: json['status'] == 1 ? true : false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
