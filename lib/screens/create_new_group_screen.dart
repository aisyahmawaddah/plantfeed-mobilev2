import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plant_feed/providers/user_model_provider.dart';
import 'package:provider/provider.dart';

import '../Services/services.dart';

class CreateNewGroupScreen extends StatefulWidget {
  const CreateNewGroupScreen({Key? key}) : super(key: key);

  @override
  State<CreateNewGroupScreen> createState() => _CreateNewGroupScreenState();
}

TextEditingController groupNameController = TextEditingController();
TextEditingController aboutGroupController = TextEditingController();
TextEditingController groupStateController = TextEditingController();
File? photo;
final _formKey = GlobalKey<FormState>();
// TextEditingController groupNameController = TextEditingController();

class _CreateNewGroupScreenState extends State<CreateNewGroupScreen> {
  @override
  Widget build(BuildContext context) {
    ApiService apiService = Provider.of<ApiService>(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.green,
        title: const Text(
          'Create a New Group',
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
                      .createNewGroup(
                    groupNameController.text,
                    aboutGroupController.text,
                    userProvider.getUser?.id ?? 0,
                    photo,
                    "test",
                    groupStateController.text,
                  )
                      .then((value) {
                    setState(() {
                      groupNameController.clear();
                      aboutGroupController.clear();
                      photo = null;
                    });
                    if (!context.mounted) return;

                    Navigator.pop(context, true);
                  });
                  log(response.toString());
                } catch (e) {
                  log(e.toString());
                }
              }
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(const Color.fromARGB(255, 16, 99, 19)),
            ),
            child: const Text(
              'Create',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    maxLines: 1,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Group name is empty";
                      } else {
                        return null;
                      }
                    },
                    onChanged: (value) {},
                    controller: groupNameController,
                    decoration: InputDecoration(
                      label: const Text('Group Name'),
                      labelStyle: const TextStyle(color: Colors.black),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.green),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      hintText: 'Group Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    maxLines: 1,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "State is empty";
                      } else {
                        return null;
                      }
                    },
                    onChanged: (value) {},
                    controller: groupStateController,
                    decoration: InputDecoration(
                      label: const Text('State'),
                      labelStyle: const TextStyle(color: Colors.black),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.green),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      hintText: 'State',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    maxLines: 3,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "About group is empty";
                      } else {
                        return null;
                      }
                    },
                    onChanged: (value) {},
                    controller: aboutGroupController,
                    decoration: InputDecoration(
                      label: const Text('About Group'),
                      labelStyle: const TextStyle(color: Colors.black),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.green),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      hintText: 'About',
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
                    child: const Text('Upload Photo'),
                  ),
                  if (photo != null)
                    Stack(
                      children: [
                        Container(
                          color: Colors.amber,
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
                    )
                ],
              )),
        ),
      ),
    );
  }
}
