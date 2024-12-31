class BookedWorkshopModel {
  final int id;
  final String programmeName;
  final String date;
  final int bookWorkshopId;
  final int participantId;
  final String messages;
  final String poster;
  final String description;
  final String venue;
  final String startTime;
  final String speaker;
  BookedWorkshopModel(
      {required this.id,
      required this.programmeName,
      required this.date,
      required this.bookWorkshopId,
      required this.participantId,
      required this.messages,
      required this.poster,
      required this.description,
      required this.venue,
      required this.startTime,
      required this.speaker});

  factory BookedWorkshopModel.fromJson(Map<String, dynamic> json) {
    return BookedWorkshopModel(
      id: json['id'],
      programmeName: json['ProgrammeName'] ?? '',
      date: json['Date'] ?? '',
      bookWorkshopId: json['BookWorkshop_id'] ?? '',
      participantId: json['Participant_id'] ?? '',
      messages: json['Messages'] ?? '',
      poster: json['Poster'] ?? '',
      description: json['Description'] ?? '',
      venue: json['Venue'] ?? '',
      startTime: json['StartTime'] ?? '',
      speaker: json['Speaker'] ?? '',
    );
  }
}
