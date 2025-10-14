import 'package:flutter/material.dart';

/// Controller class to handle PostCardModel actions from external widgets
class PostCardController {
  VoidCallback? _translateCallback;
  
  /// Set the translate callback that will be called when translation is requested
  void setTranslateCallback(VoidCallback callback) {
    _translateCallback = callback;
  }
  
  /// Trigger translation
  void translate() {
    _translateCallback?.call();
  }
  
  /// Clear the callback when disposing
  void dispose() {
    _translateCallback = null;
  }
}