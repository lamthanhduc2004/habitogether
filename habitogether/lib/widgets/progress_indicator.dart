import 'package:flutter/material.dart';

class CustomProgressIndicator extends StatelessWidget {
  final double value; // Giá trị từ 0.0 đến 1.0
  final double height;
  final Color backgroundColor;
  final Color progressColor;
  final BorderRadius? borderRadius;

  const CustomProgressIndicator({
    super.key,
    required this.value,
    this.height = 10.0,
    this.backgroundColor = Colors.grey,
    this.progressColor = Colors.blue,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
      ),
      child: FractionallySizedBox(
        widthFactor: value.clamp(0.0, 1.0),
        alignment: Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            color: progressColor,
            borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
          ),
        ),
      ),
    );
  }
}
