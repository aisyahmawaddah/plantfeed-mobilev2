class User {
  final String name, username, dateOfBirth, email, about, occupation, photo, maritalStatus, district, state;
  final int age, id;

  const User({
    required this.name,
    required this.age,
    required this.username,
    required this.dateOfBirth,
    required this.email,
    required this.id,
    required this.about,
    required this.photo,
    required this.occupation,
    required this.maritalStatus,
    required this.district,
    required this.state,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['Name'] ?? '',
      age: json['Age'] ?? 0,
      username: json['Username'] ?? '',
      dateOfBirth: json['DateOfBirth'] ?? '',
      email: json['Email'] ?? '',
      id: json['id'] ?? 0,
      occupation: json['Occupation'] ?? '',
      about: json['About'] ?? '',
      photo: json['Photo'] ?? '',
      maritalStatus: json['MaritalStatus'] ?? '',
      district: json['District'] ?? '',
      state: json['State'] ?? '',
    );
  }
}
