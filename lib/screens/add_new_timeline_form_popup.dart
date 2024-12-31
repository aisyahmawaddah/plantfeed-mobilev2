import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plant_feed/Services/services.dart';
import 'package:plant_feed/providers/user_model_provider.dart';
import 'package:provider/provider.dart';

class AddNewTimelineScreenPopup extends StatefulWidget {
  final int groupId;
  const AddNewTimelineScreenPopup({Key? key, required this.groupId}) : super(key: key);

  @override
  State<AddNewTimelineScreenPopup> createState() => _AddNewTimelineScreenPopupState();
}

class _AddNewTimelineScreenPopupState extends State<AddNewTimelineScreenPopup> {
  final _formKey = GlobalKey<FormState>();
  File? photo;
  TextEditingController titleController = TextEditingController();
  TextEditingController messageController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    ApiService apiService = Provider.of<ApiService>(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return ListView(
      children: [
        AlertDialog(
          title: const Text('Share to the group'),
          content: Form(
            key: _formKey,
            child: Wrap(children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  maxLines: 1,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Title is empty";
                    } else {
                      return null;
                    }
                  },
                  onChanged: (value) {},
                  controller: titleController,
                  decoration: InputDecoration(
                    label: const Text('Title'),
                    labelStyle: const TextStyle(color: Colors.black),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.green),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: 'Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  maxLines: 3,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Title is empty";
                    } else {
                      return null;
                    }
                  },
                  onChanged: (value) {},
                  controller: messageController,
                  decoration: InputDecoration(
                    label: const Text('Content'),
                    labelStyle: const TextStyle(color: Colors.black),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.green),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: 'Content',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
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
                await apiService.addNewGroupSharing(
                  titleController.text,
                  messageController.text,
                  userId,
                  widget.groupId,
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
