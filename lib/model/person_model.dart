// lib/models/person_model.dart

import 'package:plant_feed/config.dart';

class Person {
  final int id;
  final String username;
  final String email;
  final String? photo;
  final String name;

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
      photo: json['Photo'],
      name: json['Name'] ?? 'Unknown Name',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'Username': username,
      'Email': email,
      'photo': photo,
      'Name': name,
    };
  }

  String get photoUrl {
    if (photo != null && photo!.isNotEmpty) {
      return '${Config.apiUrl}/$photo'; 
    } else {
      return 'https://www.w3schools.com/w3images/avatar2.png'; // Placeholder image URL
    }
  }
}
