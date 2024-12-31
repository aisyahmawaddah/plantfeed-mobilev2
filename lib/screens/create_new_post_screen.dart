import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plant_feed/Services/services.dart';
import 'package:plant_feed/providers/user_model_provider.dart';
import 'package:provider/provider.dart';

class CreateNewPostScreen extends StatefulWidget {
  const CreateNewPostScreen({Key? key}) : super(key: key);

  @override
  State<CreateNewPostScreen> createState() => _CreateNewPostScreenState();
}

TextEditingController titleController = TextEditingController();
TextEditingController messageController = TextEditingController();
File? photo;
final _formKey = GlobalKey<FormState>();

class _CreateNewPostScreenState extends State<CreateNewPostScreen> {
  @override
  Widget build(BuildContext context) {
    ApiService apiService = Provider.of<ApiService>(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.green,
        title: const Text(
          'Create New Post',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                try {
                  final response = await apiService
                      .addNewPost(
                    titleController.text,
                    messageController.text,
                    userProvider.getUser?.id ?? 0,
                    photo,
                  )
                      .then((value) {
                    titleController.clear();
                    messageController.clear();
                    photo == null;
                    // Navigator.pop(context, true);
                    if (!context.mounted) return;
                    Navigator.pushNamedAndRemoveUntil(context, '/AppLayout', (route) => false);
                  });
                  log(response); // handle the response here
                } catch (e) {
                  log(e.toString()); // handle the error here
                }
              }
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(const Color.fromARGB(255, 16, 99, 19)),
            ),
            child: const Text(
              'Post',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
                key: _formKey,
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      TextFormField(
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
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        maxLines: 4,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Content is empty";
                          } else {
                            return null;
                          }
                        },
                        onChanged: (value) {},
                        controller: messageController,
                        decoration: InputDecoration(
                          label: const Text('Content'),
                          labelStyle: const TextStyle(
                            color: Colors.black,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.green),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
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
                    ],
                  ),
                )),
          ),
        ],
      ),
    );
  }
}
