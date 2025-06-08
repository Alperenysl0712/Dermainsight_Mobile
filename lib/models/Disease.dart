class Disease {
  final int id;
  final String diseaseName;
  final String imageName;
  final String? imageAr;
  final String? diseaseDetail;

  Disease({
    required this.id,
    required this.diseaseName,
    required this.imageName,
    this.imageAr,
    this.diseaseDetail
  });

  factory Disease.fromJson(Map<String, dynamic> json) {
    return Disease(
        id: json['Id'] ?? '',
        diseaseName: json['DiseaseName'] ?? '',
        imageName: json['ImageName'] ?? '',
        imageAr: json['ImageAr'] ?? '',
        diseaseDetail: json['DiseaseDetail'] ?? ''
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'DiseaseName': diseaseName,
      'ImageName': imageName,
      'ImageAr': imageAr,
      'DiseaseDetail': diseaseDetail
    };
  }
}

class DiseaseTr {
  static const Map<String, String> disTrList = {
    "nevus": "Nevus - {Ben}",
    "melanoma": "Melanoma - {Melanom}",
    "seborrheic keratosis": "Seborrheic Keratosis - {Seboreik Keratoz}",
    "dermatofibroma": "Dermatofibroma - {Dermatofibrom}",
    "basal cell carcinoma": "Basal Cell Carcinoma - {Bazal Hücreli Karsinom}",
    "squamous cell carcinoma": "Squamous Cell Carcinoma - {Skuamöz Hücreli Karsinom}",
    "verruca": "Verruca - {Siğil}",
    "pigmented benign keratosis": "Pigmented Benign Keratosis - {Pigmente İyi Huylu Keratoz}"
  };
}

class DiseaseUploadRequest {
  final String diseaseName;
  final String imageBase64;

  DiseaseUploadRequest({required this.diseaseName, required this.imageBase64});

  Map<String, dynamic> toJson() => {
    'disease_name': diseaseName,
    'image_base64': imageBase64,
  };
}

