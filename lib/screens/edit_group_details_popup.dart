import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plant_feed/providers/user_model_provider.dart';
import 'package:provider/provider.dart';

import '../Services/services.dart';

class EditGroupDetailFormScreen extends StatefulWidget {
  final String groupName;
  final String aboutGroup;
  final String state;
  final String groupPhoto;
  final int groupId;
  const EditGroupDetailFormScreen({Key? key, required this.groupName, required this.aboutGroup, required this.state, required this.groupPhoto, required this.groupId}) : super(key: key);

  @override
  State<EditGroupDetailFormScreen> createState() => _EditProfileFormScreenState();
}

class _EditProfileFormScreenState extends State<EditGroupDetailFormScreen> {
  final _formKey = GlobalKey<FormState>();
  File? photo;

  TextEditingController groupNameController = TextEditingController();
  TextEditingController aboutGroupController = TextEditingController();
  TextEditingController stateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    ApiService apiService = Provider.of<ApiService>(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    String getPlaceholderImage() {
      return 'assets/images/placeholder_image.png';
    }

    String getNetworkImageUrl() {
      if (widget.groupPhoto.isNotEmpty) {
        return "${apiService.url}/media/${widget.groupPhoto}";
      }
      return '';
    }

    ImageProvider<Object> getBackgroundImage() {
      if (photo != null) {
        return FileImage(photo!);
      } else if (getNetworkImageUrl().isNotEmpty) {
        return Image.network(getNetworkImageUrl()).image;
      } else {
        return AssetImage(getPlaceholderImage());
      }
    }

    return ListView(
      children: [
        AlertDialog(
          title: const Text('Edit Group Details'),
          content: Form(
            key: _formKey,
            child: Wrap(
              runSpacing: 20,
              children: [
                Stack(
                  children: [
                    SizedBox(
                      height: 90,
                      width: 90,
                      child: CircleAvatar(
                        backgroundImage: getBackgroundImage(),
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: InkWell(
                        onTap: () async {
                          final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                          if (pickedFile != null) {
                            setState(() {
                              photo = File(pickedFile.path);
                            });
                          }
                        },
                        child: const Icon(
                          Icons.add_a_photo_outlined,
                          size: 35,
                        ),
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Group Name is Empty";
                    } else {
                      return null;
                    }
                  },
                  onChanged: (value) {},
                  controller: groupNameController..text = widget.groupName,
                  decoration: InputDecoration(
                    labelText: 'Group Name',
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
                TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "About Group is Empty";
                    } else {
                      return null;
                    }
                  },
                  onChanged: (value) {},
                  controller: aboutGroupController..text = widget.aboutGroup,
                  decoration: InputDecoration(
                    labelText: 'About Group',
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.green),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: 'About Group',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "State is empty";
                    } else {
                      return null;
                    }
                  },
                  onChanged: (value) {},
                  controller: stateController..text = userProvider.getUser?.state ?? '',
                  decoration: InputDecoration(
                    labelText: 'State',
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
              ],
            ),
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
                await apiService
                    .updateGroup(
                  groupName: groupNameController.text,
                  aboutGroup: aboutGroupController.text,
                  state: stateController.text,
                  groupId: widget.groupId,
                  imageFile: photo,
                )
                    .then((value) {
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                  setState(() {});
                });
              },
              child: const Text('Save'),
            )
          ],
        ),
      ],
    );
  }
}
