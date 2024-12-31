class AllGroupModel {
  final int id;
  final String groupName;
  final String about;
  final String groupPicture;
  final int creatorId;
  final String state;
  final String adminName;

  AllGroupModel({
    required this.id,
    required this.groupName,
    required this.about,
    required this.groupPicture,
    required this.creatorId,
    required this.state,
    required this.adminName,
  });

  factory AllGroupModel.fromJson(Map<String, dynamic> json) {
    return AllGroupModel(
      id: json['id'],
      groupName: json['Name'] ?? '',
      about: json['About'] ?? '',
      groupPicture: json['Media'] ?? '',
      creatorId: json['Username_id'],
      state: json['State'] ?? '',
      adminName: json['Admin_name'] ?? '',
    );
  }
}
