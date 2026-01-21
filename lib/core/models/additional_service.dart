import '../database/database_constants.dart';

class AdditionalService {
  final int? id;
  final String name;
  final String? description;
  final double price;
  final String? category;
  final String createdAt;
  final String updatedAt;

  AdditionalService({
    this.id,
    required this.name,
    this.description,
    required this.price,
    this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      DatabaseConstants.columnId: id,
      DatabaseConstants.columnServiceName: name,
      DatabaseConstants.columnServiceDescription: description,
      DatabaseConstants.columnServicePrice: price,
      DatabaseConstants.columnServiceCategory: category,
      DatabaseConstants.columnCreatedAt: createdAt,
      DatabaseConstants.columnUpdatedAt: updatedAt,
    };
  }

  factory AdditionalService.fromMap(Map<String, dynamic> map) {
    return AdditionalService(
      id: map[DatabaseConstants.columnId] as int?,
      name: map[DatabaseConstants.columnServiceName] as String,
      description: map[DatabaseConstants.columnServiceDescription] as String?,
      price: (map[DatabaseConstants.columnServicePrice] as num).toDouble(),
      category: map[DatabaseConstants.columnServiceCategory] as String?,
      createdAt: map[DatabaseConstants.columnCreatedAt] as String,
      updatedAt: map[DatabaseConstants.columnUpdatedAt] as String,
    );
  }

  AdditionalService copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    String? category,
    String? createdAt,
    String? updatedAt,
  }) {
    return AdditionalService(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

