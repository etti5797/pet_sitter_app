import 'dart:math';

import 'package:flutter/material.dart';

List<String> catImages = [
  'images/cats/cat1.jpeg',
  'images/cats/cat2.jpg',
  'images/cats/cat3.jpeg',
  'images/cats/cat4.jpg',
  'images/cats/cat5.jpg',
  'images/cats/cat6.jpg',
  'images/cats/cat7.jpg',
  'images/cats/cat8.jpg',
  'images/cats/cat9.jpg',
  'images/cats/cat10.jpg',
  'images/cats/cat11.jpg',
];

List<String> dogImages = [
  'images/dogs/dog1.jpeg',
  'images/dogs/dog2.jpg',
  'images/dogs/dog3.jpg',
  'images/dogs/dog4.jpg',
  'images/dogs/dog5.jpg',
  'images/dogs/dog6.jpg',
  'images/dogs/dog7.jpg',
  'images/dogs/dog8.jpg',
  'images/dogs/dog9.jpg',
  'images/dogs/dog10.jpg',
  'images/dogs/dog11.jpg',
];

List<String> dogsCatsImages = [
  'images/dogsCats/dogcat1.jpg',
  'images/dogsCats/dogcat2.jpg',
  'images/dogsCats/dogcat3.jpg',
  'images/dogsCats/dogcat4.jpg',
  'images/dogsCats/dogcat5.jpg',
  'images/dogsCats/dogcat6.jpg',
  'images/dogsCats/dogcat7.jpg',
  'images/dogsCats/dogcat8.jpg',
  'images/dogsCats/dogcat9.jpg',
  'images/dogsCats/dogcat10.jpg',
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
