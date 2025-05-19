# ai_sensitive_content_classifier

![Pub Version](https://img.shields.io/pub/v/ai_sensitive_content_classifier)
![Dart](https://img.shields.io/badge/Dart-3.0%2B-blue)
![Flutter](https://img.shields.io/badge/Flutter-Compatible-green)

A Dart/Flutter package that classifies **text and images for sensitive content** using the [Google Generative AI](https://pub.dev/packages/google_generative_ai) (Gemini) API.

Supports input as plain text, `Uint8List`, `ui.Image`, or Flutter `ImageProvider`.

---

## 🚀 Features

- 🔍 Classifies content(text/images or bytes directly) into types like `gore`, `violence`, `nudity`, `racism`, `hateSpeech`, `offensive`, or `notSensitive`
- 🧠 Powered by Google Gemini (`gemini-2.0-flash-lite` by default)
- 🖼️ Supports direct analysis from Flutter UI images (📸 Support for `ui.Image`, `Uint8List`, or `ImageProvider` (e.g., `AssetImage`, `NetworkImage`))
- 🧪 Easily customizable model config (temperature, topP, maxOutputTokens, etc.)
- ✅ JSON schema validation for safer AI response handling
- 🧠 JSON schema validation for structured AI responses
- 🛡 No content filtering: all Gemini safety filters disabled to ensure full sensitivity analysis

---

## 🛠 Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  ai_sensitive_content_classifier: ^0.1.3
```

Then run 
```
flutter pub get
```

Usage:
```
import 'package:ai_sensitive_content_classifier/ai_sensitive_content_classifier.dart';

final classifier = AiSensitiveContentDetector(
  apiKey: 'your-gemini-api-key',
);

final result = await classifier.analyseIsSensitiveContent(
  text: 'This is a violent message',
);

print(result?.isSensitive); // true/false
print(result?.textClassification); // e.g., "violence"
```

Configurations:

```
AiSensitiveContentDetector({
  required String apiKey,
  String model = 'gemini-2.0-flash-lite',
  double temperature = 0.1,
  double topP = 0.95,
  int topK = 64,
  int maxOutputTokens = 8192,
})
```