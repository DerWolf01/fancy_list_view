import 'package:flutter/material.dart';

typedef AnimationValueGenerator<T> = T Function(BuildContext context);
typedef AnimationValueGeneratorWithProgress<T> = T Function(
    BuildContext context, double progress);

class AnimationStop<KeyType> {
  const AnimationStop(
      {required this.key, required this.x, required this.scale, this.width});
  final KeyType key;
  final AnimationValueGenerator<double> x;
  // final AnimationValueGenerator? y;
  // final AnimationValueGenerator? z;
  final AnimationValueGeneratorWithProgress<double> scale;
  final AnimationValueGenerator<double?>? width;
}
