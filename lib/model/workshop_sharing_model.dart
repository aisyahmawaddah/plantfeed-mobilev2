class WorkshopSharingModel {
  final int id;
  final String title;
  final String message;
  final String video;
  final int workshopId;
  final String photo;
  WorkshopSharingModel({
    required this.id,
    required this.title,
    required this.message,
    required this.video,
    required this.workshopId,
    required this.photo,
  });

  factory WorkshopSharingModel.fromJson(Map<String, dynamic> json) {
    return WorkshopSharingModel(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      photo: json['photo'],
      video: json['video'],
      workshopId: json['workshop_id'],
    );
  }
}
