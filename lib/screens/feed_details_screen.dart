import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:plant_feed/Services/services.dart';
import 'package:plant_feed/model/comment_model.dart';
import 'package:plant_feed/model/post_details_model.dart';
import 'package:plant_feed/model/reply_comments_model.dart';
import 'package:plant_feed/providers/user_model_provider.dart';
import 'package:plant_feed/screens/add_comment_form_popup.dart';
import 'package:plant_feed/screens/create_new_group_screen.dart';
import 'package:provider/provider.dart';

class FeedDetailScreen extends StatefulWidget {
  final int id;
  const FeedDetailScreen({Key? key, required this.id}) : super(key: key);

  @override
  State<FeedDetailScreen> createState() => _FeedDetailScreenState();
}

class _FeedDetailScreenState extends State<FeedDetailScreen> {
  PostDetailsModels? feedDetails;
  List<CommentModel>? comments;
  TextEditingController replyCommentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchComments();
  }

  Future<void> fetchComments() async {
    try {
      ApiService apiService = Provider.of<ApiService>(context, listen: false);
      final data = await apiService.getComments(widget.id);
      setState(() {
        comments = data;
      });
    } catch (e) {
      // Handle error if fetching fails
      log('Error fetching feed comments: $e');
    }
  }

  Future<void> refreshData() async {
    fetchComments();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ApiService apiService = Provider.of<ApiService>(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Comments',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildCommentsList(apiService),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          log("Feed Id:${widget.id}");
          log("Commenter Id:${userProvider.getUser?.id}");
          showDialog(
            builder: (context) {
              return AddCommentFormScreen(feedId: widget.id);
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
        CommentModel comment = comments![index];
        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                isThreeLine: true,
                dense: true,
                leading: CircleAvatar(
                  backgroundImage: (comment.commenterPicture.isNotEmpty) ? NetworkImage("${apiService.url}${comment.commenterPicture}") : const AssetImage('assets/images/placeholder_image.png') as ImageProvider,
                  backgroundColor: Colors.transparent,
                ),
                title: Text(
                  comment.commenterName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(comment.message),
                    if (comment.picture.isNotEmpty)
                      SizedBox(
                        width: 200,
                        child: Image.network(
                          "${apiService.url}${comment.picture}",
                          fit: BoxFit.scaleDown,
                        ),
                      ),
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
                                    // Handle adding reply logic
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
                                        .replyComments(
                                      replyCommentController.text,
                                      userProvider.getUser?.id ?? 1,
                                      widget.id,
                                      photo,
                                      comment.id,
                                    )
                                        .then((value) {
                                      if (!context.mounted) return;
                                      replyCommentController.clear();
                                      Navigator.pop(context);
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
                future: apiService.getReplyComments(comment.id),
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
      },
    );
  }
}
