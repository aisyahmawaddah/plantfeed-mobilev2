class MembershipModel {
  final int id;
  final int groupMemberId;
  final int usernameId;
  final String name;
  final String username;
  final String photo;
  MembershipModel({
    required this.id,
    required this.groupMemberId,
    required this.usernameId,
    required this.name,
    required this.username,
    required this.photo,
  });

  factory MembershipModel.fromJson(Map<String, dynamic> json) {
    return MembershipModel(
      id: json['id'],
      groupMemberId: json['GroupMember_id'],
      usernameId: json['Username_id'],
      name: json['name'],
      username: json['username'],
      photo: json['photo'] ?? '',
    );
  }
}
