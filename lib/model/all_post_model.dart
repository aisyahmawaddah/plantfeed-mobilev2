import 'package:intl/intl.dart';

class AllPostModel {
  final int creatorId;
  final int id;
  final String title;
  final String message;
  final String createdAt;
  final String creatorName;
  late DateTime dateString = DateTime.parse(createdAt);
  DateFormat readabableDateFormat = DateFormat("MMM dd, yyyy hh:mm:ss a");
  late String formattedDate = readabableDateFormat.format(dateString);
  final String feedImage;
  final String profilePicture;
  final String username;

  AllPostModel({
    required this.creatorId,
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.feedImage,
    required this.creatorName,
    required this.profilePicture,
    required this.username,
  });

  factory AllPostModel.fromJson(Map<String, dynamic> json) {
    return AllPostModel(
      creatorId: json['Creator_id'],
      id: json['id'],
      title: json['Title'] ?? '',
      message: json['Message'] ?? '',
      createdAt: json['created_at'] ?? '',
      feedImage: json['Photo'] ?? '',
      creatorName: json['Creator_name'] ?? '',
      profilePicture: json['Creator_photo'] ?? '',
      username: json['Creator_username'] ?? '',
    );
  }
}
