// lib/models/person_model.dart

import 'package:plant_feed/config.dart';

class Person {
  final int id;
  final String username;
  final String email;
  final String? photo; // Nullable photo
  final String name; // Added 'name' field

  Person({
    required this.id,
    required this.username,
    required this.email,
    this.photo,
    required this.name,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'] ?? 0,
      username: json['Username'] ?? 'Unknown User',
      email: json['Email'] ?? 'No Email Provided',
      photo: json['photo'], // Nullable photo field
      name: json['Name'] ?? 'Unknown Name',
    );
  }

  // Convert Person instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'Username': username,
      'Email': email,
      'photo': photo,
      'Name': name,
    };
  }

  // Helper method to get photo URL or a placeholder
  String get photoUrl => photo != null ? '${Config.apiUrl}$photo' : 'default_avatar_url';
}