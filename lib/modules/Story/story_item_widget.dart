import 'package:flutter/material.dart';

class StoryItemWidget extends StatelessWidget {
  final String imageUrl;
  final String caption;

  StoryItemWidget({required this.imageUrl, required this.caption});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.network(imageUrl),
        Text(caption),
      ],
    );
  }
}
