import 'package:flutter/material.dart';
import 'package:plant_feed/Services/services.dart';
import 'package:plant_feed/model/membership_model.dart';

class MembershipDialog extends StatefulWidget {
  final ApiService apiService;
  final List<MembershipModel> membershipList;
  const MembershipDialog({Key? key, required this.apiService, required this.membershipList}) : super(key: key);

  @override
  State<MembershipDialog> createState() => _MembershipDialogState();
}

class _MembershipDialogState extends State<MembershipDialog> {
  late List<MembershipModel> membershipList;

  @override
  void initState() {
    super.initState();
    membershipList = widget.membershipList;
  }

  Future<void> removeMember(int memberId) async {
    await widget.apiService.removeGroupMembers(memberId);
    setState(() {
      membershipList = membershipList.where((m) => m.id != memberId).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: membershipList.length,
          itemBuilder: (context, index) {
            final membership = membershipList[index];

            return ListTile(
              title: Text(membership.name),
              subtitle: Text("@${membership.username}"),
              leading: CircleAvatar(
                backgroundImage: NetworkImage("${widget.apiService.url}${membership.photo}"),
              ),
              trailing: (membership.groupMemberId != widget.apiService.id)
                  ? InkWell(
                      onTap: () => removeMember(membership.id),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                    )
                  : null,
            );
          },
        ),
      ),
    );
  }
}
