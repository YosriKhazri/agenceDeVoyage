import '../database/database_constants.dart';

class Review {
  final int? id;
  final int destinationId;
  final int clientId;
  final int rating;
  final String? comment;
  final String createdAt;
  final String updatedAt;

  Review({
    this.id,
    required this.destinationId,
    required this.clientId,
    required this.rating,
    this.comment,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      DatabaseConstants.columnId: id,
      DatabaseConstants.columnReviewDestinationId: destinationId,
      DatabaseConstants.columnReviewClientId: clientId,
      DatabaseConstants.columnReviewRating: rating,
      DatabaseConstants.columnReviewComment: comment,
      DatabaseConstants.columnCreatedAt: createdAt,
      DatabaseConstants.columnUpdatedAt: updatedAt,
    };
  }

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map[DatabaseConstants.columnId] as int?,
      destinationId: map[DatabaseConstants.columnReviewDestinationId] as int,
      clientId: map[DatabaseConstants.columnReviewClientId] as int,
      rating: map[DatabaseConstants.columnReviewRating] as int,
      comment: map[DatabaseConstants.columnReviewComment] as String?,
      createdAt: map[DatabaseConstants.columnCreatedAt] as String,
      updatedAt: map[DatabaseConstants.columnUpdatedAt] as String,
    );
  }

  Review copyWith({
    int? id,
    int? destinationId,
    int? clientId,
    int? rating,
    String? comment,
    String? createdAt,
    String? updatedAt,
  }) {
    return Review(
      id: id ?? this.id,
      destinationId: destinationId ?? this.destinationId,
      clientId: clientId ?? this.clientId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

