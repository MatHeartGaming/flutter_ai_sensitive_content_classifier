// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class AiClassificationResponse {
  final String imageClassification;
  final String textClassification;
  final bool isSensitive;

  AiClassificationResponse({
    required this.imageClassification,
    required this.textClassification,
    required this.isSensitive,
  });

  

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'imageClassification': imageClassification,
      'textClassification': textClassification,
      'isSensitive': isSensitive,
    };
  }

  factory AiClassificationResponse.fromMap(Map<String, dynamic> map) {
    return AiClassificationResponse(
      imageClassification: map['imageClassification'] as String,
      textClassification: map['textClassification'] as String,
      isSensitive: map['isSensitive'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory AiClassificationResponse.fromJson(String source) => AiClassificationResponse.fromMap(json.decode(source) as Map<String, dynamic>);

  AiClassificationResponse copyWith({
    String? imageClassification,
    String? textClassification,
    bool? isSensitive,
  }) {
    return AiClassificationResponse(
      imageClassification: imageClassification ?? this.imageClassification,
      textClassification: textClassification ?? this.textClassification,
      isSensitive: isSensitive ?? this.isSensitive,
    );
  }
}
