import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:plant_feed/Services/services.dart';
import 'package:plant_feed/providers/user_model_provider.dart';
import 'package:provider/provider.dart';

class WorkshopDetailScreen extends StatefulWidget {
  final int workshopId;
  final int userId;
  final String programmeName;
  final String date;
  final String poster;
  final String startTime;
  final String endTime;
  final String speaker;
  final String venue;
  final String state;

  const WorkshopDetailScreen({
    Key? key,
    required this.workshopId,
    required this.userId,
    required this.programmeName,
    required this.date,
    required this.poster,
    required this.startTime,
    required this.endTime,
    required this.speaker,
    required this.venue,
    required this.state,
  }) : super(key: key);

  @override
  State<WorkshopDetailScreen> createState() => _WorkshopDetailScreenState();
}

class _WorkshopDetailScreenState extends State<WorkshopDetailScreen> {
  @override
  Widget build(BuildContext context) {
    ApiService apiService = Provider.of<ApiService>(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return ListView(
      children: [
        AlertDialog(
          title: Text(widget.programmeName),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Date: ${widget.date}"),
              Text("Time: ${widget.startTime} - ${widget.endTime}"),
              Text('Speaker: ${widget.speaker}'),
              Text('Venue: ${widget.venue}'),
              Text('State: ${widget.state}'),
              Card(
                child: Container(
                  width: double.maxFinite,
                  height: 100,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.scaleDown,
                      image: (widget.poster.isNotEmpty) ? NetworkImage(widget.poster) : const AssetImage('assets/images/placeholder_image.png') as ImageProvider<Object>,
                    ),
                  ),
                ),
              )
            ],
          ),
          actions: [
            MaterialButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
            MaterialButton(
              onPressed: () async {
                String formattedDate = DateFormat('yyyy-MM-dd').format(DateFormat('dd MMM yyyy').parse(widget.date));

                await apiService
                    .bookWorkshop(
                  widget.userId,
                  widget.workshopId,
                  widget.programmeName,
                  formattedDate,
                  "",
                )
                    .then((value) {
                  if (value == true) {
                    // if (!mounted) return;
                    apiService.sendEmailBooking(
                      userProvider.getUser?.name ?? '',
                      userProvider.getUser?.email ?? '',
                      "You successfully booked this workshop held on ${widget.date} at ${widget.startTime}",
                      "Workshop ${widget.programmeName}",
                    );

                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Book Successful.'),
                      ),
                    );

                    Navigator.of(context).pop();
                  } else {
                    if (!context.mounted) return;
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Already Booked'),
                          content: const Text('You have already booked this workshop.'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('OK'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                });
              },
              child: const Text('Book Workshop'),
            ),
          ],
        )
      ],
    );
  }
}
