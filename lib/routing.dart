import 'package:flutter/material.dart';
import 'package:plant_feed/Screens/login_screen.dart';
import 'package:plant_feed/Screens/profile_screen.dart';
import 'package:plant_feed/Screens/register_screen.dart';
import 'package:plant_feed/screens/create_new_group_screen.dart';
import 'package:plant_feed/screens/create_new_post_screen.dart';
import 'package:plant_feed/screens/feed_details_screen.dart';
import 'package:plant_feed/screens/group_sharing_details_screen.dart';
import 'package:plant_feed/screens/group_timeline_screen.dart';
import 'package:plant_feed/screens/layout.dart';
//import 'package:plant_feed/screens/marketplace_screen.dart';
import 'package:plant_feed/screens/splash_screen.dart';
import 'package:plant_feed/screens/workshop_sharing_screen.dart';
import 'package:plant_feed/screens/marketplace_screen.dart';

class RouteGenerator {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/AppLayout':
        return MaterialPageRoute(builder: (_) => const AppLayout());
      case '/loginScreen':
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case '/registerScreen':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case '/profileScreen':
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case '/createNewPostScreen':
        return MaterialPageRoute(builder: (_) => const CreateNewPostScreen());
      case '/createNewGroupScreen':
        return MaterialPageRoute(builder: (_) => const CreateNewGroupScreen());
      case '/marketplace':
        return MaterialPageRoute(builder: (_) => const MarketplaceScreen());
      case '/feedDetail':
        final id = settings.arguments as int; // Assuming id is of type int
        return MaterialPageRoute(builder: (_) => FeedDetailScreen(id: id));
      case '/groupTimeline':
        final List<dynamic> arguments = settings.arguments as List<dynamic>;
        final int groupId = arguments[0];
        final String groupName = arguments[1];
        final String groupPicture = arguments[2];
        return MaterialPageRoute(
          builder: (_) => GroupTimelineScreen(
            groupId: groupId,
            groupName: groupName,
            groupPicture: groupPicture,
          ),
        );
      case '/groupTimelineDetails':
        final List<dynamic> arguments = settings.arguments as List<dynamic>;
        final String creatorName = arguments[0];
        final String creatorUsername = arguments[1];
        final String creatorPhoto = arguments[2];
        final String createdAt = arguments[3];
        final String groupTitle = arguments[4];
        final String groupMessage = arguments[5];
        final String groupPhoto = arguments[6];
        final int id = arguments[7];
        return MaterialPageRoute(
          builder: (_) => GroupSharingDetailScreen(
            creatorName: creatorName,
            creatorUsername: creatorUsername,
            creatorPhoto: creatorPhoto,
            createdAt: createdAt,
            groupTitle: groupTitle,
            groupMessage: groupMessage,
            groupPhoto: groupPhoto,
            id: id,
          ),
        );

      case '/workshopTimeline':
        final List<dynamic> arguments = settings.arguments as List<dynamic>;
        final String programmeName = arguments[0];
        final String poster = arguments[1];
        final int workshopId = arguments[2];
        return MaterialPageRoute(
            builder: (_) => WorkshopTimelineScreen(
                  programmeName: programmeName,
                  poster: poster,
                  workshopId: workshopId,
                ));
    }
    return null; // Return null for any unknown routes
  }
}
