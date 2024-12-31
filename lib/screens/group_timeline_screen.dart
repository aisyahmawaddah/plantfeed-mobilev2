import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:plant_feed/Services/services.dart';
import 'package:plant_feed/model/group_sharing_model.dart';
import 'package:plant_feed/screens/add_new_timeline_form_popup.dart';
import 'package:provider/provider.dart';

class GroupTimelineScreen extends StatefulWidget {
  final int groupId;
  final String groupName;
  final String groupPicture;
  const GroupTimelineScreen({Key? key, required this.groupId, required this.groupName, required this.groupPicture}) : super(key: key);

  @override
  State<GroupTimelineScreen> createState() => _GroupTimelineScreenState();
}

class _GroupTimelineScreenState extends State<GroupTimelineScreen> {
  @override
  Widget build(BuildContext context) {
    ApiService apiService = Provider.of<ApiService>(context);

    Future<void> refreshData() async {
      List<GroupSharingModel> allPosts = await apiService.getGroupTimelines(widget.groupId);

      setState(() {
        log(widget.groupId.toString());
        // Update the data for the 'Feed' tab
        Future<List<GroupSharingModel>>.value(allPosts);
      });
    }

    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(widget.groupName),
                CircleAvatar(
                  backgroundImage: ((widget.groupPicture).isNotEmpty) ? NetworkImage("${apiService.url}/media/${widget.groupPicture}") : const AssetImage('assets/images/placeholder_image.png') as ImageProvider,
                  backgroundColor: Colors.transparent,
                ),
              ],
            )),
        body: FutureBuilder<List<GroupSharingModel>>(
          future: apiService.getGroupTimelines(widget.groupId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: CircularProgressIndicator(
                    color: Colors.green,
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            } else if (snapshot.hasData) {
              if (snapshot.data!.isEmpty) {
                return RefreshIndicator(
                  onRefresh: refreshData,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      Center(
                        child: Text('No post found'),
                      ),
                    ],
                  ),
                );
              } else {
                return RefreshIndicator(
                  onRefresh: refreshData,
                  child: ListView.builder(
                    itemCount: snapshot.data?.length,
                    itemBuilder: (context, index) {
                      GroupSharingModel? groupSharing = snapshot.data?[index];
                      return InkWell(
                        onTap: () {
                          log(snapshot.data?[index].id.toString() ?? '');
                          Navigator.pushNamed(context, '/groupTimelineDetails', arguments: [
                            groupSharing?.creatorName ?? '',
                            groupSharing?.creatorUsername ?? '',
                            groupSharing?.creatorPhoto ?? '',
                            groupSharing?.createdAt ?? '',
                            groupSharing?.groupTitle ?? '',
                            groupSharing?.groupMessage ?? '',
                            groupSharing?.groupPhoto ?? '',
                            groupSharing?.id ?? '',
                          ]);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: (groupSharing?.creatorPhoto != null && (groupSharing?.creatorPhoto ?? "").isNotEmpty) ? NetworkImage("${apiService.url}${groupSharing?.creatorPhoto}") : const AssetImage('assets/images/placeholder_image.png') as ImageProvider,
                                        backgroundColor: Colors.transparent,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                        child: Text(
                                          groupSharing?.creatorName ?? '',
                                          style: const TextStyle(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          "@${groupSharing?.creatorUsername ?? ''}",
                                          style: const TextStyle(
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 50),
                                    child: Text(groupSharing?.createdAt ?? ''),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 50),
                                    child: Text(
                                      snapshot.data?[index].groupTitle ?? '',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 50),
                                    child: Text(groupSharing?.groupMessage ?? ''),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 50),
                                    child: (groupSharing?.groupPhoto != null && groupSharing!.groupPhoto.isNotEmpty)
                                        ? SizedBox(
                                            height: 250,
                                            width: 250,
                                            child: Image.network(
                                              "${apiService.url}${groupSharing.groupPhoto}",
                                            ),
                                          )
                                        : const SizedBox(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
            } else {
              return const SizedBox(); // Handle other cases if needed
            }
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          label: const Text('Create new post'),
          backgroundColor: Colors.green,
          onPressed: () {
            showDialog(
              builder: (context) {
                return AddNewTimelineScreenPopup(groupId: widget.groupId);
              },
              context: context,
              barrierDismissible: false,
            );
          },
          icon: const Icon(Icons.add),
        ));
  }
}
