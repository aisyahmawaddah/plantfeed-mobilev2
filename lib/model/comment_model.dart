class CommentModel {
  final int id;
  final int commenterId;
  final String commenterName;
  final String commenterUsername;
  final String message;
  final int feedId;
  final String commenterPicture;
  final String picture;

  CommentModel({
    required this.id,
    required this.commenterId,
    required this.commenterName,
    required this.commenterUsername,
    required this.message,
    required this.feedId,
    required this.commenterPicture,
    required this.picture,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'],
      commenterId: json['Commenter_id'],
      commenterName: json['Commenter_name'],
      commenterUsername: json['Commenter_username'],
      message: json['Message'],
      feedId: json['Feed_id'],
      commenterPicture: json['Commenter_picture'],
      picture: json['Pictures'] ?? '',
    );
  }
}
