import 'package:flutter/material.dart';
import 'package:plant_feed/Services/services.dart';
import 'package:plant_feed/model/all_group_model.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as dev;
import '../util/cache_manager_util.dart';
import '../util/cache_network_image_util.dart';

class GroupDetailScreen extends StatefulWidget {
  final int groupId;
  final int userId;
  const GroupDetailScreen({Key? key, required this.groupId, required this.userId, required groupName}) : super(key: key);

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  AllGroupModel? groupModel;

  @override
  void initState() {
    super.initState();
    fetchGroupDetails();
  }

  Future<void> fetchGroupDetails() async {
    try {
      ApiService apiService = Provider.of<ApiService>(context, listen: false);
      final data = await apiService.getGroupDetails(widget.groupId);
      setState(() {
        groupModel = data;
      });
    } catch (e) {
      // Handle error if fetching fails
      dev.log('Error fetching group details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    ApiService apiService = Provider.of<ApiService>(context);
    return ListView(
      children: [
        AlertDialog(
          title: Text(groupModel?.groupName ?? ''),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Card(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CustomCachedNetworkImage(
                      width: 90,
                      height: 100,
                      imageUrl: groupModel?.groupPicture ?? '',
                      cacheManager: CustomCacheManager().customCacheManager,
                      errorWidget: const Icon(Icons.person),
                    ),
                  ),
                ),
              ),
              Text("About: ${groupModel?.about}"),
              Text("Created by: ${groupModel?.adminName}"),
              Text("State: ${groupModel?.state}"),
            ],
          ),
          actions: [
            MaterialButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
            MaterialButton(
              onPressed: () async {
                await apiService.joinNewGroup(widget.userId, widget.groupId).then((result) {
                  if (!context.mounted) return;
                  if (result == true) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Success'),
                          content: const Text('Group membership added successfully.'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('OK'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Already Joined'),
                          content: const Text('You have already joined this group.'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('OK'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                });
              },
              child: const Text('Join Group'),
            ),
          ],
        )
      ],
    );
  }
}
