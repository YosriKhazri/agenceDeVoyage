import '../database/database_constants.dart';

class Destination {
  final int? id;
  final String name;
  final String country;
  final String? city;
  final String? imageUrl;
  final String? description;
  final double basePrice;
  final String createdAt;
  final String updatedAt;

  Destination({
    this.id,
    required this.name,
    required this.country,
    this.city,
    this.imageUrl,
    this.description,
    required this.basePrice,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      DatabaseConstants.columnId: id,
      DatabaseConstants.columnDestinationName: name,
      DatabaseConstants.columnDestinationCountry: country,
      DatabaseConstants.columnDestinationCity: city,
      DatabaseConstants.columnDestinationImageUrl: imageUrl,
      DatabaseConstants.columnDestinationDescription: description,
      DatabaseConstants.columnDestinationBasePrice: basePrice,
      DatabaseConstants.columnCreatedAt: createdAt,
      DatabaseConstants.columnUpdatedAt: updatedAt,
    };
  }

  factory Destination.fromMap(Map<String, dynamic> map) {
    return Destination(
      id: map[DatabaseConstants.columnId] as int?,
      name: map[DatabaseConstants.columnDestinationName] as String,
      country: map[DatabaseConstants.columnDestinationCountry] as String,
      city: map[DatabaseConstants.columnDestinationCity] as String?,
      imageUrl: map[DatabaseConstants.columnDestinationImageUrl] as String?,
      description: map[DatabaseConstants.columnDestinationDescription] as String?,
      basePrice: (map[DatabaseConstants.columnDestinationBasePrice] as num).toDouble(),
      createdAt: map[DatabaseConstants.columnCreatedAt] as String,
      updatedAt: map[DatabaseConstants.columnUpdatedAt] as String,
    );
  }

  Destination copyWith({
    int? id,
    String? name,
    String? country,
    String? city,
    String? imageUrl,
    String? description,
    double? basePrice,
    String? createdAt,
    String? updatedAt,
  }) {
    return Destination(
      id: id ?? this.id,
      name: name ?? this.name,
      country: country ?? this.country,
      city: city ?? this.city,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      basePrice: basePrice ?? this.basePrice,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

