  import 'package:flutter/material.dart';
  
  String getPetTypeFromList(List<dynamic> petType) {
    if (petType.length == 2) {
      return 'dogsCats';
    }
    if (petType[0] == 'Dogs') {
      return 'dogs';
    } else if (petType[0] == 'Cats') {
      return 'cats';
    }
    return 'dogsCats';
  }