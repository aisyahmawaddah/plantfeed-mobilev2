class GroupCommentModel {
  final int id;
  final String groupMessage;
  final String groupVideo;
  final int groupCommenterId;
  final int groupFeedFKId;
  final String groupPhoto;
  final String commenterName;
  final String commenterPhoto;
  final String commenterUsername;
  GroupCommentModel({
    required this.id,
    required this.groupMessage,
    required this.groupVideo,
    required this.groupPhoto,
    required this.groupCommenterId,
    required this.groupFeedFKId,
    required this.commenterName,
    required this.commenterPhoto,
    required this.commenterUsername,
  });
  factory GroupCommentModel.fromJson(Map<String, dynamic> json) {
    return GroupCommentModel(
      id: json['id'],
      groupMessage: json['GrpMessage'],
      groupVideo: json['GrpVideo'] ?? '',
      groupPhoto: json['GrpPictures'] ?? '',
      groupCommenterId: json['GrpCommenterFK_id'],
      groupFeedFKId: json['GrpFeedFK_id'],
      commenterName: json['commenter_name'],
      commenterPhoto: json['commenter_photo'],
      commenterUsername: json['commenter_username'],
    );
  }
}
