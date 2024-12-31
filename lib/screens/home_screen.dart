import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:plant_feed/model/all_post_model.dart';
import 'package:plant_feed/model/my_post_model.dart';
import 'package:plant_feed/screens/feed_details_screen.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import '../Services/services.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({Key? key}) : super(key: key);

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {}); // Trigger a rebuild when the tab changes
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ApiService apiService = Provider.of<ApiService>(context);

    Future<void> refreshData() async {
      List<AllPostModel> allPosts = await apiService.getAllPost();
      List<MyPostModel> myPosts = await apiService.getMyPost();

      setState(() {
        // Update the data for the 'Feed' tab
        Future<List<AllPostModel>>.value(allPosts);

        // Update the data for the 'My Posts' tab
        Future<List<MyPostModel>>.value(myPosts);
      });
    }

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Column(
        children: [
          TabBar(
            labelColor: Colors.black,
            indicatorColor: Colors.green,
            controller: _tabController,
            tabs: const [
              Tab(text: 'Feed'),
              Tab(text: 'My Posts'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                FutureBuilder<List<AllPostModel>>(
                  key: const PageStorageKey('FeedTab'),
                  future: apiService.getAllPost(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data!.isEmpty) {
                        return RefreshIndicator(
                          onRefresh: refreshData,
                          child: ListView(
                            children: const [
                              Center(
                                child: Text('No post found'),
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
                            itemCount: snapshot.data?.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                  left: 8,
                                  right: 8,
                                  bottom: 10,
                                ),
                                child: Card(
                                  child: InkWell(
                                    onTap: () {
                                      showModalBottomSheet<dynamic>(
                                        context: context,
                                        builder: (context) {
                                          return ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), child: FeedDetailScreen(id: snapshot.data![index].id));
                                        },
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                backgroundImage: (snapshot.data?[index].profilePicture != null && (snapshot.data?[index].profilePicture ?? "").isNotEmpty) ? NetworkImage("${apiService.url}${snapshot.data?[index].profilePicture}") : const AssetImage('assets/images/placeholder_image.png') as ImageProvider,
                                                backgroundColor: Colors.transparent,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 8),
                                                child: Text(
                                                  snapshot.data?[index].creatorName ?? '',
                                                  style: const TextStyle(
                                                    fontSize: 10.5,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 8.0),
                                                child: Text("@${snapshot.data?[index].username ?? ''}"),
                                              ),
                                              InkWell(
                                                onTap: () async {
                                                  await Share.share(
                                                    snapshot.data?[index].message ?? '',
                                                    subject: snapshot.data?[index].title,
                                                  );
                                                  if (snapshot.data?[index].feedImage != null && snapshot.data![index].feedImage.isNotEmpty) {
                                                    final urlImage = "${apiService.url}${snapshot.data![index].feedImage}";
                                                    final url = Uri.parse(urlImage);
                                                    final response = await http.get(url);
                                                    final bytes = response.bodyBytes;
                                                    final temp = await getTemporaryDirectory();
                                                    final path = '${temp.path}/image.jpg';

                                                    File(path).writeAsBytesSync(bytes);
                                                    await Share.shareXFiles(
                                                      [XFile(path)],
                                                      subject: snapshot.data?[index].title ?? '',
                                                      text: snapshot.data?[index].message ?? '',
                                                    );
                                                  }
                                                },
                                                child: const Icon(
                                                  Icons.share,
                                                  size: 18,
                                                ),
                                              )
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 50),
                                            child: Text(snapshot.data?[index].formattedDate ?? ''),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 50),
                                            child: Text(
                                              snapshot.data?[index].title ?? '',
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 50),
                                            child: Text(snapshot.data?[index].message ?? ''),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 50),
                                            child: (snapshot.data?[index].feedImage != null && snapshot.data![index].feedImage.isNotEmpty) ? Image.network("${apiService.url}${snapshot.data![index].feedImage}") : const SizedBox(),
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
                    } else if (snapshot.hasError) {
                      return Text(snapshot.error.toString());
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
                FutureBuilder<List<MyPostModel>>(
                  key: const PageStorageKey('MyPostsTab'),
                  future: apiService.getMyPost(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data!.isEmpty) {
                        return RefreshIndicator(
                            onRefresh: refreshData,
                            child: ListView(
                              children: const [
                                Center(
                                  child: Text('No post found'),
                                ),
                              ],
                            ));
                      } else {
                        return RefreshIndicator(
                          color: Colors.green,
                          onRefresh: refreshData,
                          child: ListView.builder(
                            itemCount: snapshot.data?.length,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  log(snapshot.data?[index].id.toString() ?? '');
                                  showModalBottomSheet<dynamic>(
                                    context: context,
                                    builder: (context) {
                                      return ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), child: FeedDetailScreen(id: snapshot.data![index].id));
                                    },
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundImage: (snapshot.data?[index].profilePicture != null && (snapshot.data?[index].profilePicture ?? "").isNotEmpty) ? NetworkImage("${apiService.url}${snapshot.data?[index].profilePicture}") : const AssetImage('assets/images/placeholder_image.png') as ImageProvider,
                                            backgroundColor: Colors.transparent,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 8),
                                            child: Text(
                                              snapshot.data?[index].creatorName ?? '',
                                              style: const TextStyle(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 8.0),
                                            child: Text("@${snapshot.data?[index].username ?? ''}"),
                                          ),
                                          Expanded(
                                            child: Align(
                                              alignment: Alignment.topRight,
                                              child: PopupMenuButton<String>(
                                                onSelected: (value) async {
                                                  if (value == 'delete') {
                                                    final postId = snapshot.data?[index].id;
                                                    if (postId != null) {
                                                      await apiService.deletePost(postId).then((value) {
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
                                            ),
                                          )
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 50),
                                        child: Text(snapshot.data?[index].formattedDate ?? ''),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 50),
                                        child: Text(
                                          snapshot.data?[index].title ?? '',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 50),
                                        child: Text(snapshot.data?[index].message ?? ''),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 50),
                                        child: (snapshot.data?[index].feedImage != null && snapshot.data![index].feedImage.isNotEmpty) ? Image.network("${apiService.url}${snapshot.data![index].feedImage}") : const SizedBox(),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }
                    } else if (snapshot.hasError) {
                      return Text(snapshot.error.toString());
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
