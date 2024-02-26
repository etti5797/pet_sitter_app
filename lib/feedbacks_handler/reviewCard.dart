import 'package:flutter/material.dart';

class ReviewCard extends StatelessWidget {
  final Map<String, dynamic> review;

  ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Card(
        child: ListTile(
          title: Text(review['reviewerName']),
          subtitle: Text(review['reviewText']),
        ),
      ),
    );
  }
}