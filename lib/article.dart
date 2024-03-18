import 'package:cloud_firestore/cloud_firestore.dart';

class Article {
  final String headline;
  final String url;
  final String imageUrl;
  final Timestamp timestamp;

  factory Article.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Article(
        url: data?['url'],
        headline: data?['headline'],
        imageUrl: data?['image_url'],
        timestamp: data?['timestamp']);
  }

  Article(
      {required this.headline,
      required this.url,
      required this.imageUrl,
      required this.timestamp});

  Map<String, dynamic> toFirestore() {
    return {
      "url": url,
      "image_url": imageUrl,
      "timestamp": timestamp,
      "headline": headline,
    };
  }
}
