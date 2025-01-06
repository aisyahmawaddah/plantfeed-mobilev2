// lib/models/review_model.dart

import 'package:plant_feed/model/person_model.dart'; // Import the shared Person class


class Review {
  final int id; // Review ID
  final String content; // Review text
  final String date; // Review date
  final Person reviewer; // Reviewer's Person object

  Review({
    required this.id,
    required this.content,
    required this.date,
    required this.reviewer,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? 0,
      content: json['content'] ?? 'No Review Content',
      date: json['date'] ?? 'Unknown Date',
      reviewer: Person.fromJson(json['reviewer'] ?? {}),
    );
  }

  // Convert Review instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'date': date,
      'reviewer': reviewer.toJson(),
    };
  }

  // Helper method for formatted date
  String get formattedDate => date; // Customize as per required format
}
