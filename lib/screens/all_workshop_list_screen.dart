import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:plant_feed/Services/services.dart';
import 'package:plant_feed/model/all_workshop_list_model.dart';
import 'package:plant_feed/providers/user_model_provider.dart';
import 'package:plant_feed/screens/workshop_details_popup.dart';
import 'package:provider/provider.dart';

class AllWorkshopTab extends StatefulWidget {
  const AllWorkshopTab({Key? key}) : super(key: key);

  @override
  State<AllWorkshopTab> createState() => _AllWorkshopTabState();
}

class _AllWorkshopTabState extends State<AllWorkshopTab> {
  AsyncSnapshot<List<AllWorkshopModel>>? allWorkshopSnapshot;
  TextEditingController searchWorkshopController = TextEditingController();
  List<AllWorkshopModel> filteredList = [];
  late DateTime today;

  @override
  void initState() {
    super.initState();
    today = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    ApiService apiService = Provider.of<ApiService>(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    Future<void> refreshData() async {
      List<AllWorkshopModel> allPosts = await apiService.getAllWorkshopList();

      setState(() {
        allWorkshopSnapshot = AsyncSnapshot<List<AllWorkshopModel>>.withData(ConnectionState.done, allPosts);
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
                    filteredList = [];
                  } else {
                    filteredList = allWorkshopSnapshot!.data!
                        .where(
                          (workshop) =>
                              workshop.programmeName.toLowerCase().contains(value.toLowerCase()) ||
                              workshop.state.toLowerCase().contains(value.toLowerCase()),
                        )
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
          child: FutureBuilder<List<AllWorkshopModel>>(
            key: const PageStorageKey('AllWorkshopTab'),
            future: apiService.getAllWorkshopList(),
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
                        final registrationDueDate = DateFormat('dd MMM yyyy').parse(workshop.registrationDue);

                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            shadowColor: Colors.black,
                            elevation: 5,
                            child: ListTile(
                              dense: true,
                              onTap: () {
                                if (registrationDueDate.isAfter(today)) {
                                  showDialog(
                                    builder: (context) {
                                      return WorkshopDetailScreen(
                                        workshopId: workshop.id,
                                        programmeName: workshop.programmeName,
                                        userId: userProvider.getUser?.id ?? 1,
                                        date: workshop.date,
                                        poster: workshop.poster,
                                        startTime: workshop.startTime,
                                        endTime: workshop.endTime,
                                        speaker: workshop.speaker,
                                        venue: workshop.venue,
                                        state: workshop.state,
                                      );
                                    },
                                    context: context,
                                    barrierDismissible: false,
                                  );
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Registration Closed'),
                                        content: const Text('Registration for this workshop is already closed.'),
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
                              },
                              leading: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: workshop.poster.isNotEmpty
                                        ? NetworkImage(workshop.poster)
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
                                    "State: ${workshop.state}",
                                  ),
                                  Text(
                                    "About: ${workshop.description}",
                                  ),
                                  Text(
                                    "Due: ${workshop.registrationDue}",
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
            },
          ),
        ),
      ],
    );
  }
}
