import 'package:ai_sensitive_content_classifier/ai_sensitive_content_classifier.dart';
import 'package:flutter/material.dart';
import 'package:ai_sensitive_content_classifier/models/ai_classification_response.dart';

void main() {
  runApp(const MyApp());
}

/// A simple demo app that analyzes an asset image and optional text.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sensitive Content Classifier Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const ContentCheckPage(),
    );
  }
}

class ContentCheckPage extends StatefulWidget {
  const ContentCheckPage({super.key});

  @override
  State<ContentCheckPage> createState() => _ContentCheckPageState();
}

class _ContentCheckPageState extends State<ContentCheckPage> {
  AiClassificationResponse? _result;
  bool _isLoading = false;
  final _classifier = AiTextImageClassifier(
    apiKey: 'YOUR_GEMINI_API_KEY', // 🔐 Replace with your actual key
  );

  Future<void> _classifyImage() async {
    setState(() => _isLoading = true);

    final result =
        await _classifier.analyseIsSensitiveContentFromImageProvider(
      imageProvider: const AssetImage('assets/images/no_wifi.jpg'),
      text: 'This image might contain sensitive content.',
    );

    setState(() {
      _result = result;
      _isLoading = false;
    });
  }

  Widget _buildResult() {
    if (_isLoading) {
      return const CircularProgressIndicator();
    }

    if (_result == null) {
      return const Text('No classification yet.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Image Classification: ${_result!.imageClassification}'),
        Text('Text Classification: ${_result!.textClassification}'),
        Text('Is Sensitive: ${_result!.isSensitive ? 'Yes' : 'No'}'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Content Classifier Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('Press the button to classify image sensitivity.'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _classifyImage,
              child: const Text('Analyze Asset Image'),
            ),
            const SizedBox(height: 20),
            _buildResult(),
          ],
        ),
      ),
    );
  }
}
