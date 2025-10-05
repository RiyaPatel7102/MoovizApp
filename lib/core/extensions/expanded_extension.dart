import 'package:flutter/material.dart';

extension WidgetExtension on Widget {
  Widget get expanded => Expanded(
        child: this,
      );

  Widget get center => Center(
        child: this,
      );
}
