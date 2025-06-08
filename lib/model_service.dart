import 'dart:typed_data';
import 'package:pytorch_lite/pytorch_lite.dart';

class ModelService{
  ClassificationModel? _model;

  Future<void> loadModel() async{

    _model = await PytorchLite.loadClassificationModel(
      "assets/models/siamese_model.pt",
      128,
      128,
      1,
      labelPath: null
    );
  }

  Future<List<double>?> predict(Uint8List imageBytes) async{
    if(_model == null) throw Exception("Model Yüklenemedi");
    return await _model!.getImagePredictionList(imageBytes);
  }

}