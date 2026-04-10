class CategoryModel {
  CategoryModel({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  final String id;
  final String name;
  final DateTime createdAt;

  CategoryModel copyWith({String? id, String? name, DateTime? createdAt}) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
