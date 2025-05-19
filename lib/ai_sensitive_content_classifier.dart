/// A classifier for detecting sensitive content in text or images using
/// Google's Gemini API.
///
/// This implementation supports image classification from raw bytes,
/// `ui.Image`, or Flutter `ImageProvider` sources, and classifies both
/// visual and textual content into categories such as `gore`, `nudity`,
/// `racism`, or `notSensitive`.
///
/// To use this class, instantiate it with a required API key and optionally
/// customize parameters like temperature, model, topP, etc.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:ai_sensitive_content_classifier/interfaces/generative_expense_ai_datasource.dart';
import 'package:ai_sensitive_content_classifier/models/ai_classification_response.dart';
import 'package:flutter/services.dart'; // for ByteData
import 'package:flutter/material.dart';

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:logger/logger.dart';

/// Enum representing all possible classification outcomes
/// for sensitive content detection.
enum SensitiveClassificanResult {
  none,
  gore,
  violence,
  nudity,
  racism,
  hateSpeech,
  offensive,
  notSensitive,
}

/// A service class that uses the Google Generative AI Gemini model
/// to classify text and/or image input as sensitive or not.
///
/// This class supports multiple input types (raw bytes, `ui.Image`,
/// `ImageProvider`) and can be easily extended or configured for
/// fine-tuned sensitivity detection.
///
/// Typical usage:
/// ```dart
/// final classifier = AiTextImageClassifier(apiKey: 'your-key');
/// final result = await classifier.analyseIsSensitiveContent(text: '...');
/// ```
class AiTextImageClassifier implements AiSensitiveClassifier {
  final _logger = Logger();

  /// Prompt used to guide the Gemini model in classification tasks.
  final String textPrompt =
      "Classify images or sentences as sensitive or not. I need you to disclose between different types of sensistive content: 'gore', 'violence', 'nudity', 'racism', 'hateSpeech', 'offensive', 'notSensitive'. If an image is not provided use 'none' as the classification result. If no text is provided use 'none' as classification result.";

  late final GenerativeModel _geminiModel;

  /// Creates an instance of [AiTextImageClassifier].
  ///
  /// [apiKey] is required to authenticate with Google's Gemini API.
  /// Optional parameters allow customization of generation behavior:
  /// [model], [temperature], [topP], [topK], [maxOutputTokens].
  AiTextImageClassifier({
    required String apiKey,
    String model = 'gemini-2.0-flash-lite',
    double temperature = 0.1,
    double topP = 0.95,
    int topK = 64,
    int maxOutputTokens = 8192,
  }) {
    _geminiModel = GenerativeModel(
      model: model,
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: temperature,
        topP: topP,
        topK: topK,
        maxOutputTokens: maxOutputTokens,
        responseMimeType: "application/json",
        responseSchema: Schema.object(
          properties: {
            'imageClassification': Schema.string(nullable: false),
            'textClassification': Schema.string(nullable: false),
            'isSensitive': Schema.boolean(nullable: false),
          },
          requiredProperties: [
            'imageClassification',
            'textClassification',
            'isSensitive',
          ],
        ),
      ),
      safetySettings: [
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
      ],
    );
  }

  /// Classifies the content from both optional [receiptImageBytes] and [text]
  /// for sensitive categories using Gemini.
  ///
  /// If [receiptImageBytes] is null, only the [text] is classified.
  /// If both are null or empty, it returns `null`.
  ///
  /// Returns an [AiClassificationResponse] or `null` in case of error.
  @override
  Future analyseIsSensitiveContent({
    Uint8List? receiptImageBytes,
    String text = '',
  }) async {
    final systemPrompt = TextPart(textPrompt);
    final userPrompt = TextPart(text);
    DataPart? image;
    if (receiptImageBytes != null) {
      image = DataPart('image/jpeg', receiptImageBytes);
    }
    try {
      GenerateContentResponse response;
      if (image != null) {
        response = await _geminiModel.generateContent([
          Content.multi([systemPrompt, userPrompt, image]),
        ]);
      } else {
        response = await _geminiModel.generateContent([
          Content.multi([systemPrompt, userPrompt]),
        ]);
      }
      String? jsonString = response.text;

      if (jsonString == null || jsonString.isEmpty) return null;
      Map<String, dynamic> resultMap = jsonDecode(jsonString);

      final result = AiClassificationResponse.fromMap(resultMap);
      return result;
    } catch (e) {
      _logger.e('Error while analysing content: $e');
      return null;
    }
  }

  /// Accepts a [ui.Image], converts it to bytes, and delegates to
  /// [analyseIsSensitiveContent].
  ///
  /// Useful when working with `Canvas`, `RepaintBoundary`, or Flutter rendering APIs.
  @override
  Future<AiClassificationResponse?> analyseIsSensitiveContentFromImage({
    required ui.Image image,
    String text = '',
  }) async {
    try {
      // Convert ui.Image to Uint8List
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;

      final Uint8List imageBytes = byteData.buffer.asUint8List();

      // Call the existing function with converted bytes
      return await analyseIsSensitiveContent(
        receiptImageBytes: imageBytes,
        text: text,
      );
    } catch (e) {
      _logger.e('Error while converting to bytes: $e');
      return null;
    }
  }

  /// Accepts an [ImageProvider], resolves it into an image, converts it to
  /// bytes, and passes it to [analyseIsSensitiveContent].
  ///
  /// This is the most convenient method when using `AssetImage`, `NetworkImage`,
  /// or any [ImageProvider] in a Flutter UI context.
  @override
  Future<AiClassificationResponse?> analyseIsSensitiveContentFromImageProvider({
    required ImageProvider imageProvider,
    String text = '',
  }) async {
    try {
      // Load and decode the image from the provider
      final ImageStream stream = imageProvider.resolve(
        ImageConfiguration.empty,
      );
      final Completer<ui.Image> completer = Completer<ui.Image>();

      late ImageStreamListener listener;
      listener = ImageStreamListener(
        (ImageInfo info, bool synchronousCall) {
          completer.complete(info.image);
          stream.removeListener(listener);
        },
        onError: (dynamic error, StackTrace? stackTrace) {
          completer.completeError(error, stackTrace);
          stream.removeListener(listener);
        },
      );

      stream.addListener(listener);

      final ui.Image uiImage = await completer.future;

      // Convert ui.Image to Uint8List
      final ByteData? byteData = await uiImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) return null;

      final Uint8List imageBytes = byteData.buffer.asUint8List();

      // Call the existing analysis function
      return await analyseIsSensitiveContent(
        receiptImageBytes: imageBytes,
        text: text,
      );
    } catch (e) {
      _logger.e('Error while converting to bytes: $e');
      return null;
    }
  }
}
