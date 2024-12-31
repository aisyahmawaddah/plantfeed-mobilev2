import 'package:flutter/material.dart';
import 'package:plant_feed/Screens/profile_screen.dart';
import 'package:plant_feed/component/floating_action_button_component.dart';
import 'package:plant_feed/screens/workshop_screen.dart';
import 'package:plant_feed/screens/marketplace_screen.dart';
import '../component/app_bar_component.dart';
import 'group_screen.dart';
import 'home_screen.dart';

class AppLayout extends StatefulWidget {
  final int selectedIndex; // To accept the selected index

  const AppLayout({Key? key, this.selectedIndex = 0}) : super(key: key);

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex; // Set the index from the widget
  }


  final List<Widget> _screens = [
    const HomeFeedScreen(),
    const GroupScreen(),
    const WorkshopScreen(),
    const MarketplaceScreen(), 
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: buildFloatingActionButton(_selectedIndex, context, () {}),
      appBar: appBarComponent(context),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        fixedColor: Colors.green,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Groups'),
          BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'Workshops'),
          BottomNavigationBarItem(icon: Icon(Icons.shop), label: 'Marketplace'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
