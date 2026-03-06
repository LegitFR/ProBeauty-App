import 'package:flutter/material.dart';

class ExploreProvider with ChangeNotifier {
  List<Map<String, String>> services = [
    {
      "id": "1",
      "title": "Haircut",
      "img": "assets/images/services/haircut.png",
    },
    {
      "id": "2",
      "title": "Hair Spa",
      "img": "assets/images/services/spa.png",
    },
    {
      "id": "3",
      "title": "Facial",
      "img": "assets/images/services/facial.png",
    },
    {
      "id": "4",
      "title": "Manicure",
      "img": "assets/images/services/nail.png",
    },
  ];
}
