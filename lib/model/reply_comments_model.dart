class ReplyCommentsModel {
  final int id;
  final int commentedId;
  final String commenterName;
  final String message;
  final int feedId;
  final String commenterPicture;
  // final String picture;

  ReplyCommentsModel({
    required this.id,
    required this.commentedId,
    required this.commenterName,
    required this.message,
    required this.feedId,
    required this.commenterPicture,
    // required this.picture,
  });

  factory ReplyCommentsModel.fromJson(Map<String, dynamic> json) {
    return ReplyCommentsModel(
      id: json['id'],
      commentedId: json['commenter_id'],
      commenterName: json['Commenter_name'],
      message: json['message'],
      feedId: json['feed_id'],
      commenterPicture: json['Commenter_picture'],
      // picture: json['pictures']??'',
    );
  }
}
