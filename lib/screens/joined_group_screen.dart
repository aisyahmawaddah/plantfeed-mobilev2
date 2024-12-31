import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:plant_feed/Services/services.dart';
import 'package:plant_feed/model/all_group_model.dart';
import 'package:plant_feed/model/joined_group_model.dart';
import 'package:plant_feed/model/membership_model.dart';
import 'package:plant_feed/screens/edit_group_details_popup.dart';
import 'package:plant_feed/screens/membership_dialog.dart';
import 'package:provider/provider.dart';

class JoinedGroupTab extends StatefulWidget {
  const JoinedGroupTab({Key? key}) : super(key: key);

  @override
  State<JoinedGroupTab> createState() => _JoinedGroupTabState();
}

class _JoinedGroupTabState extends State<JoinedGroupTab> {
  AsyncSnapshot<List<AllGroupModel>>? allGroupSnapshot;

  AsyncSnapshot<List<JoineGroupModel>>? joinedGroupSnapshot;
  TextEditingController searchJoinedGroupController = TextEditingController();
  List<JoineGroupModel> filteredJoinedList = [];
  @override
  Widget build(BuildContext context) {
    ApiService apiService = Provider.of<ApiService>(context);
    Future<void> refreshData() async {
      List<JoineGroupModel> allJoinedGroup = await apiService.getJoinedGroupList();

      setState(() {
        joinedGroupSnapshot = AsyncSnapshot<List<JoineGroupModel>>.withData(ConnectionState.done, allJoinedGroup);
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            height: 45,
            width: 300,
            child: TextFormField(
              controller: searchJoinedGroupController,
              onChanged: (value) {
                setState(() {
                  if (value.isEmpty) {
                    filteredJoinedList = []; // Clear the filtered list
                  } else {
                    filteredJoinedList = joinedGroupSnapshot!.data!.where((group) => group.groupName.toLowerCase().contains(value.toLowerCase()) || group.state.toLowerCase().contains(value.toLowerCase())).toList();
                  }
                });
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.green),
                  borderRadius: BorderRadius.circular(10),
                ),
                hintText: 'Search',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<JoineGroupModel>>(
            key: const PageStorageKey('JoinedGroup'),
            future: apiService.getJoinedGroupList(),
            builder: (context, snapshot) {
              joinedGroupSnapshot = snapshot;
              if (snapshot.hasData) {
                if (snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No Group '),
                  );
                } else {
                  return RefreshIndicator(
                    color: Colors.green,
                    onRefresh: refreshData,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: filteredJoinedList.isNotEmpty ? filteredJoinedList.length : snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final group = filteredJoinedList.isNotEmpty ? filteredJoinedList[index] : snapshot.data![index];
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            shadowColor: Colors.black,
                            elevation: 5,
                            child: ListTile(
                              trailing: (group.adminId == apiService.id)
                                  ? PopupMenuButton<String>(
                                      onSelected: (value) async {
                                        if (value == 'Update Group Info') {
                                          log(group.adminId.toString());
                                          log(apiService.id.toString());
                                          showDialog(
                                            builder: (context) {
                                              return EditGroupDetailFormScreen(
                                                groupName: group.groupName,
                                                aboutGroup: group.aboutGroup,
                                                state: group.state,
                                                groupPhoto: group.groupPicture,
                                                groupId: group.groupNameId,
                                              );
                                            },
                                            context: context,
                                            barrierDismissible: false,
                                          );
                                        }
                                        if (value == 'View Members') {
                                          showDialog(
                                            context: context,
                                            barrierDismissible: true,
                                            builder: (context) {
                                              return FutureBuilder<List<MembershipModel>>(
                                                future: apiService.getMembershipList(group.groupNameId), // Call the API function here
                                                builder: (context, snapshot) {
                                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                                    return const CircularProgressIndicator();
                                                  } else if (snapshot.hasError) {
                                                    return Text('Error: ${snapshot.error}');
                                                  } else if (!snapshot.hasData) {
                                                    return const Text('No data available');
                                                  } else {
                                                    final membershipList = snapshot.data!;

                                                    return MembershipDialog(
                                                      apiService: apiService,
                                                      membershipList: membershipList,
                                                    );
                                                  }
                                                },
                                              );
                                            },
                                          );
                                        }
                                      },
                                      itemBuilder: (BuildContext context) => [
                                        const PopupMenuItem<String>(
                                          value: 'Update Group Info',
                                          child: Text('Update Group Info'),
                                        ),
                                        const PopupMenuItem<String>(
                                          value: 'View Members',
                                          child: Text('View Members'),
                                        ),
                                      ],
                                      child: const Icon(Icons.more_horiz),
                                    )
                                  : null,
                              onTap: () {
                                Navigator.pushNamed(context, '/groupTimeline', arguments: [
                                  group.groupNameId,
                                  group.groupName,
                                  group.groupPicture,
                                ]);
                              },
                              leading: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: (group.groupPicture.isNotEmpty) ? NetworkImage("${apiService.url}/media/${group.groupPicture}") : const AssetImage('assets/images/placeholder_image.png') as ImageProvider<Object>,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              title: Text(
                                group.groupName,
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    group.aboutGroup,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black54,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                  Text(
                                    group.state,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Text("Joined on: ${group.getFormattedJoinedOn()}")
                                ],
                              ),
                              isThreeLine: true,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
              } else if (snapshot.hasError) {
                return Text(snapshot.hasError.toString());
              }
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: CircularProgressIndicator(
                    color: Colors.green,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
