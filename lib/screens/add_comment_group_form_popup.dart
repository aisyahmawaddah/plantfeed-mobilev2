import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plant_feed/Services/services.dart';
import 'package:plant_feed/providers/user_model_provider.dart';
import 'package:provider/provider.dart';

class AddCommentGroupPopupScreen extends StatefulWidget {
  final int feedId;
  const AddCommentGroupPopupScreen({Key? key, required this.feedId}) : super(key: key);

  @override
  State<AddCommentGroupPopupScreen> createState() => _AddCommentFormScreenState();
}

class _AddCommentFormScreenState extends State<AddCommentGroupPopupScreen> {
  final _formKey = GlobalKey<FormState>();
  File? photo;
  TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ApiService apiService = Provider.of<ApiService>(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return ListView(
      children: [
        AlertDialog(
          title: const Text('Add Comment'),
          content: Form(
            key: _formKey,
            child: Wrap(children: [
              TextFormField(
                maxLines: 3,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Your Comment";
                  } else {
                    return null;
                  }
                },
                onChanged: (value) {},
                controller: commentController,
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
              ElevatedButton(
                onPressed: () async {
                  final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() {
                      photo = File(pickedFile.path);
                    });
                  }
                },
                child: const Text(
                  'Upload Photo',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              if (photo != null)
                Stack(
                  children: [
                    Container(
                      color: Colors.red,
                      width: 150,
                      height: 150,
                    ),
                    Image.file(
                      photo!,
                      width: 300,
                      height: 300,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 5,
                      right: 5,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            photo = null;
                          });
                        },
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ]),
          ),
          actions: [
            MaterialButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            MaterialButton(
              onPressed: () async {
                int userId = userProvider.getUser?.id ?? 1;
                await apiService.addNewCommentGroup(
                  commentController.text,
                  userId,
                  widget.feedId,
                  photo,
                );
                if (!context.mounted) return;
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            )
          ],
        )
      ],
    );
  }
}
