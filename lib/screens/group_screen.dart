import 'package:flutter/material.dart';
import 'package:plant_feed/model/all_group_model.dart';
import 'package:plant_feed/model/joined_group_model.dart';
import 'package:plant_feed/screens/all_group_screen.dart';
import 'package:plant_feed/screens/joined_group_screen.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen({Key? key}) : super(key: key);

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  AsyncSnapshot<List<AllGroupModel>>? allGroupSnapshot;

  AsyncSnapshot<List<JoineGroupModel>>? joinedGroupSnapshot;
  TextEditingController searchAllGroupController = TextEditingController();
  TextEditingController searchJoinedGroupController = TextEditingController();
  List<AllGroupModel> filteredList = [];
  List<JoineGroupModel> filteredJoinedList = [];

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
    // ApiService apiService = Provider.of<ApiService>(context);

    // // Future<void> refreshData() async {
    // //   List<AllGroupModel> allPosts = await apiService.getAllGroupList();
    // //   List<JoineGroupModel> allJoinedGroup = await apiService.getJoinedGroupList();

    // //   setState(() {
    // //     // Update the snapshot data with the new list
    // //     allGroupSnapshot = AsyncSnapshot<List<AllGroupModel>>.withData(ConnectionState.done, allPosts);
    // //     joinedGroupSnapshot = AsyncSnapshot<List<JoineGroupModel>>.withData(ConnectionState.done, allJoinedGroup);
    // //   });
    // // }

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Column(
        children: [
          TabBar(
            indicatorColor: Colors.green,
            controller: _tabController,
            tabs: const [
              Tab(text: 'All Group'),
              Tab(text: 'Joined Group'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                AllGroupTab(),
                JoinedGroupTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
