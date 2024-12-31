import 'package:intl/intl.dart';

class JoineGroupModel {
  final int id;
  final DateTime joinedOn;
  final int groupMemberId;
  final String groupName;
  final String groupPicture;
  final String aboutGroup;
  final int groupNameId;
  final int adminId;
  final String state;

  JoineGroupModel(
      {required this.id,
      required this.joinedOn,
      required this.groupMemberId,
      required this.groupName,
      required this.groupPicture,
      required this.aboutGroup,
      required this.groupNameId,
      required this.adminId,
      required this.state});

  factory JoineGroupModel.fromJson(Map<String, dynamic> json) {
    return JoineGroupModel(
        id: json['id'],
        joinedOn: DateTime.parse(json['joined_on']),
        groupMemberId: json['GroupMember_id'],
        groupName: json['GroupName'],
        groupPicture: json['Media'],
        aboutGroup: json['About'],
        groupNameId: json['GroupName_id'],
        adminId: json['Username_id'],
        state: json['State']);
  }

  String getFormattedJoinedOn() {
    final formatter = DateFormat('MMMM d, y, hh:mm a');
    return formatter.format(joinedOn);
  }
}
