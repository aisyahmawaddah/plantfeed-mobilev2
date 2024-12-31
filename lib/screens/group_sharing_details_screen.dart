import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:plant_feed/Services/services.dart';
import 'package:plant_feed/model/group_comment_model.dart';
import 'package:plant_feed/model/reply_comments_model.dart';
import 'package:plant_feed/providers/user_model_provider.dart';
import 'package:plant_feed/screens/add_comment_group_form_popup.dart';
import 'package:plant_feed/screens/create_new_group_screen.dart';
import 'package:provider/provider.dart';

class GroupSharingDetailScreen extends StatefulWidget {
  final String creatorName;
  final String creatorUsername;
  final String creatorPhoto;
  final String createdAt;
  final String groupTitle;
  final String groupMessage;
  final String groupPhoto;
  final int id;
  const GroupSharingDetailScreen({
    Key? key,
    required this.creatorName,
    required this.creatorUsername,
    required this.creatorPhoto,
    required this.createdAt,
    required this.groupTitle,
    required this.groupMessage,
    required this.groupPhoto,
    required this.id,
  }) : super(key: key);

  @override
  State<GroupSharingDetailScreen> createState() => _GroupSharingDetailScreenState();
}

class _GroupSharingDetailScreenState extends State<GroupSharingDetailScreen> {
  List<GroupCommentModel>? comments;
  @override
  void initState() {
    super.initState();

    fetchComments();
  }

  Future<void> fetchComments() async {
    try {
      ApiService apiService = Provider.of<ApiService>(context, listen: false);
      final data = await apiService.getGroupComments(widget.id);
      setState(() {
        comments = data;
      });
    } catch (e) {
      // Handle error if fetching fails
      log('Error fetching feed comments: $e');
    }
  }

  TextEditingController replyCommentController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    ApiService apiService = Provider.of<ApiService>(context);
    Future<void> refreshData() async {
      fetchComments();

      setState(() {});
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.green,
        title: const Text(
          'Sharing Details',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: RefreshIndicator(
          onRefresh: refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: ((widget.creatorPhoto).isNotEmpty) ? NetworkImage("${apiService.url}${widget.creatorPhoto}") : const AssetImage('assets/images/placeholder_image.png') as ImageProvider,
                      backgroundColor: Colors.transparent,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        widget.creatorName,
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.black, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          "@${widget.creatorUsername}",
                          style: const TextStyle(overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 50),
                  child: Text(widget.createdAt),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 50),
                  child: Text(
                    widget.groupTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 50),
                  child: Text(
                    widget.groupMessage,
                  ),
                ),
                Center(
                  child: (widget.groupPhoto.isNotEmpty) ? SizedBox(height: 300, width: 300, child: Image.network("${apiService.url}${widget.groupPhoto}")) : const SizedBox(),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Comments',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                buildCommentsList(apiService)
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          log(widget.id.toString());
          showDialog(
            builder: (context) {
              return AddCommentGroupPopupScreen(feedId: widget.id);
            },
            context: context,
            barrierDismissible: false,
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.comment),
      ),
    );
  }

  Widget buildCommentsList(ApiService apiService) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: comments?.length ?? 0,
        itemBuilder: (context, index) {
          return Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  isThreeLine: true,
                  dense: true,
                  leading: CircleAvatar(
                    backgroundImage: (comments?[index].commenterPhoto != null && (comments?[index].commenterPhoto ?? "").isNotEmpty) ? NetworkImage("${apiService.url}${comments?[index].commenterPhoto}") : const AssetImage('assets/images/placeholder_image.png') as ImageProvider,
                    backgroundColor: Colors.transparent,
                  ),
                  title: Text(
                    comments?[index].commenterName ?? '',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(comments?[index].groupMessage ?? ''),
                      (comments?[index].groupPhoto != null && comments![index].groupPhoto.isNotEmpty)
                          ? SizedBox(
                              width: 200,
                              child: Image.network(
                                "${apiService.url}${comments?[index].groupPhoto}",
                                fit: BoxFit.scaleDown,
                              ),
                            )
                          : const SizedBox(),
                      TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Reply to Comment'),
                                content: TextFormField(
                                  controller: replyCommentController,
                                  maxLines: 3,
                                  decoration: InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(color: Colors.green),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    hintText: 'Your Comment',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                ),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      await apiService
                                          .replyGroupComments(
                                        replyCommentController.text,
                                        userProvider.getUser?.id ?? 1,
                                        widget.id,
                                        photo,
                                        comments![index].id,
                                      )
                                          .then((value) {
                                        replyCommentController.clear();
                                        if (!context.mounted) return;
                                        Navigator.pop(context);
                                        setState(() {});
                                      });
                                    },
                                    child: const Text(
                                      'Reply',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: const Text(
                          'Reply',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
                FutureBuilder<List<ReplyCommentsModel>>(
                  future: apiService.getGroupReplyComments(comments![index].id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return const Text('Failed to fetch reply comments');
                    } else if (snapshot.hasData) {
                      List<ReplyCommentsModel> replyComments = snapshot.data!;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: replyComments.length,
                        itemBuilder: (context, replyIndex) {
                          ReplyCommentsModel reply = replyComments[replyIndex];
                          return Padding(
                            padding: const EdgeInsets.all(6),
                            child: Card(
                              shadowColor: Colors.black,
                              elevation: 10,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: (reply.commenterPicture.isNotEmpty) ? NetworkImage("${apiService.url}${reply.commenterPicture}") : const AssetImage('assets/images/placeholder_image.png') as ImageProvider,
                                  backgroundColor: Colors.transparent,
                                ),
                                dense: true,
                                title: Text(
                                  reply.commenterName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(reply.message),
                                // Add additional UI elements for each reply as needed
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
              ],
            ),
          );
        });
  }
}
