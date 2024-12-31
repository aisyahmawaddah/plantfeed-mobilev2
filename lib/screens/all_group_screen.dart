import 'package:flutter/material.dart';
import 'package:plant_feed/Services/services.dart';
import 'package:plant_feed/model/all_group_model.dart';
import 'package:plant_feed/model/joined_group_model.dart';
import 'package:plant_feed/screens/group_details_popup.dart';
import 'package:plant_feed/util/cache_network_image_util.dart';
import 'package:provider/provider.dart';

import '../providers/user_model_provider.dart';
import '../util/cache_manager_util.dart';

class AllGroupTab extends StatefulWidget {
  const AllGroupTab({Key? key}) : super(key: key);

  @override
  State<AllGroupTab> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<AllGroupTab> {
  AsyncSnapshot<List<AllGroupModel>>? allGroupSnapshot;

  AsyncSnapshot<List<JoineGroupModel>>? joinedGroupSnapshot;
  TextEditingController searchAllGroupController = TextEditingController();

  List<AllGroupModel> filteredList = [];

  @override
  Widget build(BuildContext context) {
    ApiService apiService = Provider.of<ApiService>(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    Future<void> refreshData() async {
      List<AllGroupModel> allPosts = await apiService.getAllGroupList();
      List<JoineGroupModel> allJoinedGroup = await apiService.getJoinedGroupList();

      setState(() {
        // Update the snapshot data with the new list
        allGroupSnapshot = AsyncSnapshot<List<AllGroupModel>>.withData(ConnectionState.done, allPosts);
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
              controller: searchAllGroupController,
              onChanged: (value) {
                setState(() {
                  if (value.isEmpty) {
                    filteredList = []; // Clear the filtered list
                  } else {
                    filteredList = allGroupSnapshot!.data!.where((group) => group.groupName.toLowerCase().contains(value.toLowerCase()) || group.state.toLowerCase().contains(value.toLowerCase())).toList();
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
          child: FutureBuilder<List<AllGroupModel>>(
            key: const PageStorageKey('AllGroupTab'),
            future: apiService.getAllGroupList(),
            builder: (context, snapshot) {
              // Assign the snapshot value to the variable
              allGroupSnapshot = snapshot;

              if (snapshot.hasData) {
                if (snapshot.data!.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: refreshData,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        Center(
                          child: Text('No Group '),
                        ),
                      ],
                    ),
                  );
                } else {
                  return RefreshIndicator(
                    color: Colors.green,
                    onRefresh: refreshData,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: filteredList.isNotEmpty ? filteredList.length : snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final group = filteredList.isNotEmpty ? filteredList[index] : snapshot.data![index];
                        return Padding(
                          padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                          child: Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            shadowColor: Colors.black,
                            elevation: 5,
                            child: ListTile(
                              onTap: () {
                                showDialog(
                                  builder: (context) {
                                    return GroupDetailScreen(
                                      groupName: group.groupName,
                                      groupId: group.id,
                                      userId: userProvider.getUser!.id,
                                    );
                                  },
                                  context: context,
                                  barrierDismissible: false,
                                );
                              },
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: CustomCachedNetworkImage(
                                  width: 90,
                                  height: 100,
                                  imageUrl: '${apiService.url}${group.groupPicture}',
                                  cacheManager: CustomCacheManager().customCacheManager,
                                  errorWidget: SizedBox(
                                    height: 150,
                                    child: Image.asset('assets/images/placeholder_image.png'),
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
                                    group.about,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Text(
                                    group.state,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black54,
                                    ),
                                  ),
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
