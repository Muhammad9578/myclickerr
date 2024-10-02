class Category {
  int id;
  String name;
  bool isSelected;

  Category(this.id, this.name, [this.isSelected = false]);

  factory Category.fromJson(Map<String, dynamic> data) {
    return Category(data['id'], data['category_name'], data['isSelected'] ?? false);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'category_name': name,
      'isSelected': isSelected,
    };

    return data;
  }
}
