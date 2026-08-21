class Review {
  final String author;
  final String content;
  final double? rating;
  final String createdAt;
  final String? avatarPath;

  Review({
    required this.author,
    required this.content,
    this.rating,
    required this.createdAt,
    this.avatarPath,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    final authorDetails = json['author_details'] ?? {};
    double? ratingVal;
    if (authorDetails['rating'] != null) {
      ratingVal = (authorDetails['rating'] as num).toDouble();
    }

    String? avatar = authorDetails['avatar_path'];
    if (avatar != null && avatar.startsWith('/')) {
      // Bỏ dấu gạch chéo đầu nếu có để xử lý URL ảnh đại diện của TMDB
      avatar = avatar.substring(1);
    }

    return Review(
      author: json['author'] ?? 'Anonymous',
      content: json['content'] ?? '',
      rating: ratingVal,
      createdAt: json['created_at'] ?? '',
      avatarPath: avatar,
    );
  }
}