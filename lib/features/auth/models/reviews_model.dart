class Review {
  final int? id;
  final int productId;
  final int? customerId;
  final String? customerAuthId;
  final int rating;
  final String? comment;
  final DateTime? reviewDate;
  final DateTime? createdAt;

  Review({
    this.id,
    required this.productId,
    this.customerId,
    this.customerAuthId,
    required this.rating,
    this.comment,
    this.reviewDate,
    this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as int?,
      productId: json['product_id'] as int,
      customerId: json['customer_id'] as int?,
      customerAuthId: json['customer_auth_id'] as String?,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      reviewDate: json['review_date'] != null
          ? DateTime.parse(json['review_date'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'customer_id': customerId,
      'customer_auth_id': customerAuthId,
      'rating': rating,
      'comment': comment,
      'review_date': reviewDate?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }
}