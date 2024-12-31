import 'package:flutter/material.dart';
import 'package:plant_feed/providers/user_model_provider.dart';
import 'package:provider/provider.dart';
import '../Services/services.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _DashboardState();
}

class _DashboardState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ApiService apiService = Provider.of<ApiService>(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Consumer<UserProvider>(builder: (
                context,
                userProvider,
                child,
              ) {
                return Row(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 90,
                      width: 90,
                      child: CircleAvatar(
                        backgroundImage: userProvider.getUser?.photo != null && userProvider.getUser!.photo.isNotEmpty
                            ? NetworkImage("${apiService.url}${userProvider.getUser?.photo}")
                            : const AssetImage('assets/images/placeholder_image.png') as ImageProvider,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userProvider.getUser?.name ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                          Text("@${userProvider.getUser?.username ?? ''}"),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ),
            _itemWidget(context, title: "Name", content: Text(userProvider.getUser?.name ?? '')),
            _itemWidget(context, title: "Email", content: Text(userProvider.getUser?.email ?? '')),
            _itemWidget(context, title: "Username", content: Text(userProvider.getUser?.username ?? '')),
            _itemWidget(context, title: "Age", content: Text(userProvider.getUser?.age.toString() ?? '')),
            _itemWidget(context, title: "About", content: Text(userProvider.getUser?.about ?? '')),
            _itemWidget(context, title: "Date of Birth", content: Text(userProvider.getUser?.dateOfBirth ?? '')),
            _itemWidget(context, title: "Occupation", content: Text(userProvider.getUser?.occupation ?? '')),
            _itemWidget(context, title: "Marital Status", content: Text(userProvider.getUser?.maritalStatus ?? '')),
            _itemWidget(context, title: "State", content: Text(userProvider.getUser?.state ?? '')),
            _itemWidget(context, title: "District", content: Text(userProvider.getUser?.district ?? '')),
          ],
        ));
  }
}

Widget _itemWidget(
  final BuildContext context, {
  required final String title,
  required final Widget content,
}) {
  return Padding(
    padding: const EdgeInsets.only(
      left: 32.0,
      bottom: 16.0,
    ),
    child: Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            title,
            style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(
          width: 32.0,
        ),
        Expanded(
          child: content,
        ),
      ],
    ),
  );
}
