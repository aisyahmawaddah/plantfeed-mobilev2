import 'package:flutter/material.dart';
import 'package:plant_feed/model/all_workshop_list_model.dart';
import 'package:plant_feed/screens/all_workshop_list_screen.dart';
import 'package:plant_feed/screens/booked_workshop_list_screen.dart';

class WorkshopScreen extends StatefulWidget {
  const WorkshopScreen({Key? key}) : super(key: key);

  @override
  State<WorkshopScreen> createState() => _WorkshopScreenState();
}

class _WorkshopScreenState extends State<WorkshopScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  AsyncSnapshot<List<AllWorkshopModel>>? allGroupSnapshot;
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
  Widget build(BuildContext context) {
    // ApiService apiService = Provider.of<ApiService>(context);

    // Future<void> refreshData() async {
    //   List<AllWorkshopModel> allWorkshop = await apiService.getAllWorkshopList();

    //   setState(() {
    //     // Update the snapshot data with the new list
    //     allGroupSnapshot = AsyncSnapshot<List<AllWorkshopModel>>.withData(ConnectionState.done, allWorkshop);
    //     // joinedGroupSnapshot = AsyncSnapshot<List<JoineGroupModel>>.withData(ConnectionState.done, allJoinedGroup);
    //   });
    // }

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.green,
            tabs: const [
              Tab(text: 'Workshop List'),
              Tab(text: 'Booked Workshop'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                AllWorkshopTab(),
                BookWorkshopTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
