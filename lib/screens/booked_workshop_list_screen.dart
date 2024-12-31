import 'package:flutter/material.dart';
import 'package:plant_feed/Services/services.dart';
import 'package:plant_feed/model/booked_workshop_model.dart';
import 'package:provider/provider.dart';

class BookWorkshopTab extends StatefulWidget {
  const BookWorkshopTab({Key? key}) : super(key: key);

  @override
  State<BookWorkshopTab> createState() => _AllWorkshopTabState();
}

class _AllWorkshopTabState extends State<BookWorkshopTab> {
  AsyncSnapshot<List<BookedWorkshopModel>>? allWorkshopSnapshot;
  TextEditingController searchWorkshopController = TextEditingController();
  List<BookedWorkshopModel> filteredList = [];
  @override
  Widget build(BuildContext context) {
    ApiService apiService = Provider.of<ApiService>(context);

    Future<void> refreshData() async {
      List<BookedWorkshopModel> allPosts = await apiService.getBookedWorkshop();
      // List<JoineGroupModel> allJoinedGroup = await apiService.getJoinedGroupList();

      setState(() {
        // Update the snapshot data with the new list
        allWorkshopSnapshot = AsyncSnapshot<List<BookedWorkshopModel>>.withData(ConnectionState.done, allPosts);
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
              controller: searchWorkshopController,
              onChanged: (value) {
                setState(() {
                  if (value.isEmpty) {
                    filteredList = []; // Clear the filtered list
                  } else {
                    filteredList = allWorkshopSnapshot!.data!
                        .where((workshop) => workshop.programmeName.toLowerCase().contains(value.toLowerCase()))
                        .toList();
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
            child: FutureBuilder<List<BookedWorkshopModel>>(
                key: const PageStorageKey('BookedWorkshopTab'),
                future: apiService.getBookedWorkshop(),
                builder: (context, snapshot) {
                  allWorkshopSnapshot = snapshot;
                  if (snapshot.hasData) {
                    if (snapshot.data!.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: refreshData,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            Center(
                              child: Text('No Workshop '),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return RefreshIndicator(
                        onRefresh: refreshData,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: filteredList.isNotEmpty ? filteredList.length : snapshot.data!.length,
                          itemBuilder: ((context, index) {
                            final workshop = filteredList.isNotEmpty ? filteredList[index] : snapshot.data![index];
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Card(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                shadowColor: Colors.black,
                                elevation: 5,
                                child: ListTile(
                                  trailing: PopupMenuButton<String>(
                                    onSelected: (value) async {
                                      if (value == 'delete') {
                                        final postId = snapshot.data?[index].id;
                                        if (postId != null) {
                                          await apiService.cancelBooking(workshop.id).then((value) {
                                            refreshData();
                                          });
                                        }
                                      }
                                    },
                                    itemBuilder: (BuildContext context) => [
                                      const PopupMenuItem<String>(
                                        value: 'delete',
                                        child: Text('Delete'),
                                      ),
                                    ],
                                    child: const Icon(Icons.more_horiz),
                                  ),
                                  dense: true,
                                  onTap: () {
                                    debugPrint("${workshop.bookWorkshopId}");
                                    Navigator.pushNamed(context, '/workshopTimeline', arguments: [
                                      workshop.programmeName,
                                      workshop.poster,
                                      workshop.bookWorkshopId,
                                    ]);
                                  },
                                  leading: Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: (workshop.poster.isNotEmpty)
                                            ? NetworkImage("${apiService.url}${workshop.poster}")
                                            : const AssetImage('assets/images/placeholder_image.png')
                                                as ImageProvider<Object>,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    "${workshop.programmeName}(${workshop.speaker})",
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 10.5,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Date: ${workshop.date}",
                                      ),
                                      Text(
                                        "Time: ${workshop.startTime}",
                                      ),
                                      Text(
                                        "Venue: ${workshop.venue}",
                                      ),
                                      Text(
                                        "About: ${workshop.description}",
                                      ),
                                    ],
                                  ),
                                  isThreeLine: true,
                                ),
                              ),
                            );
                          }),
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
                }))
      ],
    );
  }
}
