import 'package:intl/intl.dart';

class PostDetailsModels {
  final int id;
  final int creatorId;
  final String title;
  final String message;
  final String postedPicture;
  final String createdAt;
  late DateTime dateString = DateTime.parse(createdAt);
  DateFormat readabableDateFormat = DateFormat("MMM dd, yyyy hh:mm:ss a");
  late String formattedDate = readabableDateFormat.format(dateString);
  final String creatorName;
  final String profilePicture;
  final String username;

  PostDetailsModels({
    required this.id,
    required this.creatorId,
    required this.title,
    required this.message,
    required this.postedPicture,
    required this.createdAt,
    required this.creatorName,
    required this.profilePicture,
    required this.username,
  });
  factory PostDetailsModels.fromJson(Map<String, dynamic> json) {
    return PostDetailsModels(
      id: json['id'] ?? '',
      creatorId: json['Creator_id'] ?? '',
      title: json['Title'] ?? '',
      message: json['Message'] ?? '',
      postedPicture: json['Photo'] ?? '',
      createdAt: json['created_at'] ?? '',
      creatorName: json['Creator_name'] ?? '',
      profilePicture: json['Profile_picture'] ?? '',
      username: json['Creator_username'] ?? '',
    );
  }
}
