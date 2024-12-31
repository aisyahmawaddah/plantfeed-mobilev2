import 'package:flutter/material.dart';
import 'package:plant_feed/Services/services.dart';
import 'package:plant_feed/model/workshop_sharing_model.dart';
import 'package:provider/provider.dart';

class WorkshopTimelineScreen extends StatefulWidget {
  final int workshopId;
  final String programmeName;
  final String poster;
  const WorkshopTimelineScreen({Key? key, required this.programmeName, required this.poster, required this.workshopId})
      : super(key: key);

  @override
  State<WorkshopTimelineScreen> createState() => _WorkshopTimelineScreenState();
}

class _WorkshopTimelineScreenState extends State<WorkshopTimelineScreen> {
  @override
  Widget build(BuildContext context) {
    ApiService apiService = Provider.of<ApiService>(context);

    Future<void> refreshData() async {
      List<WorkshopSharingModel> allPosts = await apiService.getWorkshopSharing(widget.workshopId);

      setState(() {
        Future<List<WorkshopSharingModel>>.value(allPosts);
      });
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(widget.programmeName),
            CircleAvatar(
              backgroundImage: ((widget.poster).isNotEmpty)
                  ? NetworkImage("${apiService.url}${widget.poster}")
                  : const AssetImage('assets/images/placeholder_image.png') as ImageProvider,
              backgroundColor: Colors.transparent,
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<WorkshopSharingModel>>(
        future: apiService.getWorkshopSharing(widget.workshopId),
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
                        WorkshopSharingModel? workshopSharing = snapshot.data?[index];
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Text(
                                    workshopSharing?.title ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: Text(workshopSharing?.message ?? ''),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 50),
                                  child: (workshopSharing?.photo != null && workshopSharing!.photo.isNotEmpty)
                                      ? SizedBox(
                                          height: 250,
                                          width: 250,
                                          child: Image.network(
                                            "${apiService.url}${workshopSharing.photo}",
                                          ),
                                        )
                                      : const SizedBox(),
                                ),
                              ],
                            ),
                          ),
                        );
                      }));
            }
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }
}
