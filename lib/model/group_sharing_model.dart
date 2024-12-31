class GroupSharingModel {
  final int id;
  final String groupTitle;
  final String groupMessage;
  final String groupSkill;
  final String groupState;
  final String groupPhoto;
  final String groupVideo;
  final String createdAt;
  final int creatorId;
  final int groupId;
  final String creatorName;
  final String creatorPhoto;
  final String creatorUsername;

  GroupSharingModel({
    required this.id,
    required this.groupTitle,
    required this.groupMessage,
    required this.groupSkill,
    required this.groupState,
    required this.groupPhoto,
    required this.groupVideo,
    required this.creatorId,
    required this.createdAt,
    required this.groupId,
    required this.creatorName,
    required this.creatorPhoto,
    required this.creatorUsername,
  });
  factory GroupSharingModel.fromJson(Map<String, dynamic> json) {
    return GroupSharingModel(
      id: json['id'],
      groupTitle: json['GroupTitle'] ?? '',
      groupMessage: json['GroupMessage'] ?? '',
      groupSkill: json['GroupMessage'] ?? '',
      groupState: json['GroupState'] ?? '',
      groupPhoto: json['GroupPhoto'] ?? '',
      groupVideo: json['GroupVideo'] ?? '',
      creatorId: json['CreatorFK_id'] ?? '',
      createdAt: json['Groupcreated_at'] ?? '',
      groupId: json['GroupFK_id'] ?? '',
      creatorName: json['creator_name'] ?? '',
      creatorPhoto: json['creator_photo'] ?? '',
      creatorUsername: json['creator_username'] ?? '',
    );
  }
}
