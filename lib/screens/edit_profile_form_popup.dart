import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plant_feed/model/user.dart';
import 'package:plant_feed/providers/user_model_provider.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as dev;
import '../Services/services.dart';

class EditProfileFormScreen extends StatefulWidget {
  const EditProfileFormScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileFormScreen> createState() => _EditProfileFormScreenState();
}

class _EditProfileFormScreenState extends State<EditProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  File? photo;

  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController districtController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    ApiService apiService = Provider.of<ApiService>(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    String getPlaceholderImage() {
      return 'assets/images/placeholder_image.png';
    }

    String getNetworkImageUrl() {
      if (userProvider.getUser?.photo != null && userProvider.getUser!.photo.isNotEmpty) {
        return "${apiService.url}${userProvider.getUser?.photo}";
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
          title: const Text('Edit Profile'),
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
                      return "Name";
                    } else {
                      return null;
                    }
                  },
                  onChanged: (value) {},
                  controller: nameController..text = userProvider.getUser?.name ?? '',
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.green),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: 'Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Age is empty";
                    } else {
                      return null;
                    }
                  },
                  onChanged: (value) {},
                  controller: ageController..text = userProvider.getUser?.age.toString() ?? '',
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.green),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: 'Age',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Username is empty";
                    } else {
                      return null;
                    }
                  },
                  onChanged: (value) {},
                  controller: usernameController..text = userProvider.getUser?.username ?? '',
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.green),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: 'Username',
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
                TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "District is empty";
                    } else {
                      return null;
                    }
                  },
                  onChanged: (value) {},
                  controller: districtController..text = userProvider.getUser?.district ?? '',
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.green),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: 'District',
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
                    .updateUser(
                  name: nameController.text,
                  age: ageController.text,
                  state: stateController.text,
                  district: districtController.text,
                  username: usernameController.text,
                  imageFile: photo,
                )
                    .then((value) {
                  userProvider.updateUser(
                    User(
                        name: nameController.text,
                        age: int.parse(ageController.text),
                        username: usernameController.text,
                        dateOfBirth: userProvider.getUser?.dateOfBirth ?? '',
                        email: userProvider.getUser?.email ?? '',
                        id: userProvider.getUser!.id,
                        about: userProvider.getUser?.about ?? '',
                        photo: userProvider.getUser?.photo ?? '',
                        occupation: userProvider.getUser?.occupation ?? '',
                        maritalStatus: userProvider.getUser?.maritalStatus ?? '',
                        district: districtController.text,
                        state: userProvider.getUser?.state ?? ''),
                  );
                  dev.log('${userProvider.getUser?.name}');
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
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
