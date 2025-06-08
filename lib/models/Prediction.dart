class Prediction {
  final String className;
  final double probability;

  Prediction({required this.className, required this.probability});

  factory Prediction.fromJson(Map<String, dynamic> json) => Prediction(
    className: json['class'],
    probability: (json['probability'] as num).toDouble(),
  );

  static List<Prediction> fromJsonList(List<dynamic> list) =>
      list.map((e) => Prediction.fromJson(e)).toList();
}
