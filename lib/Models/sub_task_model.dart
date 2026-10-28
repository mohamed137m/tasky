class SubTaskModel {
  String id;
  String title;
  bool isDone;

  SubTaskModel({
    required this.id,
    required this.title,
    this.isDone = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isDone': isDone,
    };
  }

  factory SubTaskModel.fromMap(Map<dynamic, dynamic> map) {
    return SubTaskModel(
      id: map['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: map['title']?.toString() ?? '',
      isDone: map['isDone'] as bool? ?? false,
    );
  }
}
