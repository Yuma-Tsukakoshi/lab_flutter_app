import 'package:collection/collection.dart';

class PricePoint {
  final double x;
  final double y;

  PricePoint({required this.x, required this.y});
}

List<PricePoint> get pricePoints {
  final data = <double>[11, 20, 10, 6, 5, 3, 5, 5, 30, 5];
  return data
      .mapIndexed(
          ((index, element) => PricePoint(x: index.toDouble(), y: element)))
      .toList();
}