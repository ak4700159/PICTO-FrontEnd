class User {
  final int userId;
  final String? accountName;
  final String? name;
  final String? email;
  final String? profilePath;
  final String? intro;
  final bool? profileActive;
  final String? password;

  User({
    required this.accountName,
    required this.userId,
    required this.intro,
    required this.profilePath,
    required this.name,
    required this.profileActive,
    required this.email,
    required this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    userId: json['userId'] as int,
    accountName: json['accountName'] as String?,
    intro: json['intro'] as String?,
    profilePath: json['profilePath'] as String?,
    name: json['name'] as String?,
    profileActive: json['profileActive'],
    email: json['email'] as String?,
    password: json['password'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'name': name,
    'accountName': accountName,
    'email': email,
    'profileActive': profileActive,
    'intro': intro,
    'profilePath': profilePath,
    'password': password,
  };
}