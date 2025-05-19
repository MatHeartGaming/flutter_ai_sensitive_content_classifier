import 'dart:ui' as ui;

import 'package:ai_sensitive_content_classifier/models/ai_classification_response.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class AiSensitiveClassifier {
  Future analyseIsSensitiveContent({
    Uint8List? receiptImageBytes,
    String text = '',
  });
  Future<AiClassificationResponse?> analyseIsSensitiveContentFromImageProvider({
    required ImageProvider imageProvider,
    String text = '',
  });
  Future<AiClassificationResponse?> analyseIsSensitiveContentFromImage({
    required ui.Image image,
    String text = '',
  });
}
