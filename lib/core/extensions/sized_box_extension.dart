import 'package:flutter/material.dart';
import 'package:movie_app/core/utils/sizer_utils.dart';

extension SizedBoxExtension on num {
  /// Returns a SizedBox with the given height
  SizedBox get vSpace => SizedBox(height: v);

  /// Returns a SizedBox with the given width
  SizedBox get hSpace => SizedBox(width: h);
}
