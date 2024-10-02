class EventCategory {
  int id;
  String name;

  EventCategory(this.id, this.name);

  factory EventCategory.fromJson(Map<String, dynamic> data) {
    return EventCategory(data['id'], data['category_name']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'category_name': name
    };

    return data;
  }
}
