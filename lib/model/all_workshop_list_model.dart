class AllWorkshopModel {
  final int id;
  final String programmeName;
  final String speaker;
  final String description;
  final String date;
  final String registrationDue;
  final String gender;
  final String startTime;
  final String endTime;
  final String state;
  final String venue;
  final String poster;
  final int pic;

  AllWorkshopModel({
    required this.id,
    required this.programmeName,
    required this.speaker,
    required this.description,
    required this.date,
    required this.registrationDue,
    required this.gender,
    required this.startTime,
    required this.endTime,
    required this.state,
    required this.venue,
    required this.poster,
    required this.pic,
  });

  factory AllWorkshopModel.fromJson(Map<String, dynamic> json) {
    final String date = _formatDate(json['Date'] as String);
    final String registrationDue = _formatDate(json['RegistrationDue'] as String);

    return AllWorkshopModel(
      id: json['id'] as int? ?? 0,
      programmeName: json['ProgrammeName'] as String? ?? '',
      speaker: json['Speaker'] as String? ?? '',
      description: json['Description'] as String? ?? '',
      date: date,
      registrationDue: registrationDue,
      gender: json['Gender'] as String? ?? '',
      startTime: json['StartTime'] as String? ?? '',
      endTime: json['EndTime'] as String? ?? '',
      state: json['State'] as String? ?? '',
      venue: json['Venue'] as String? ?? '',
      poster: json['Poster'] as String? ?? '',
      pic: json['PIC'] as int? ?? 0,
    );
  }

  static String _formatDate(String dateString) {
    final List<String> dateParts = dateString.split('-');
    final String day = dateParts[2];
    final String month = _getMonthName(int.parse(dateParts[1]));
    final String year = dateParts[0];
    return '$day $month $year';
  }

  static String _getMonthName(int month) {
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return monthNames[month - 1];
  }
}
