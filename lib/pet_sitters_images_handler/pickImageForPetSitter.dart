import 'dart:math';

import 'package:flutter/material.dart';

List<String> catImages = [
  'images/cats/cat1.jpeg',
  'images/cats/cat3.jpeg',
];

List<String> dogImages = [
  'images/dogs/dog1.jpeg',
  'images/dogs/dog2.jpeg',
  'images/dogs/dog3.jpeg',
  'images/dogs/dog4.PNG',
  'images/dogs/dog5.PNG',
  'images/dogs/dog6.PNG',
  'images/dogs/dog7.PNG',
  'images/dogs/dog8.PNG',
  'images/dogs/dog9.PNG',
  'images/dogs/dog10.PNG',
];

List<String> dogsCatsImages = [
  'images/dogsCats/dogcat1.jpeg',
  'images/dogsCats/dogcat2.jpeg',
];    

Map<String, List<String>> petImages = {
  'cats': catImages,
  'dogs': dogImages,
  'dogsCats': dogsCatsImages,
};

String getRandomImageUrl(String petType) {
  List<String> imagePaths = petImages[petType] ?? [];
  if (imagePaths.isEmpty) {
    return ''; // Return an empty string or handle the case where no images are available
  }

  final Random random = Random();
  final int randomIndex = random.nextInt(imagePaths.length);

  return imagePaths[randomIndex];
}

// Image loadRandomImage(String petType) {
//   String randomImagePath = getRandomImageUrl(petType);

//   return Image.asset(randomImagePath);
// }
