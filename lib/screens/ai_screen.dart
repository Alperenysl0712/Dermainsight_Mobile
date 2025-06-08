import 'dart:convert';

import 'package:dermainsight/api/disease_api.dart';
import 'package:dermainsight/base_navigator.dart';
import 'package:dermainsight/managers/error_manager.dart';
import 'package:dermainsight/models/Disease.dart';
import 'package:dermainsight/models/Prediction.dart';
import 'package:dermainsight/screens/main_menu_screen.dart';
import 'package:dermainsight/screens/real_time_camera_screen.dart';
import 'package:dermainsight/widgets/app_bar_widget.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mobkit_dashed_border/mobkit_dashed_border.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../widgets/drawer_widget.dart'; // File sınıfı için

class AiScreen extends StatefulWidget{
  File? selectedImage;
  AiScreen({this.selectedImage, super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  TextEditingController _otherTextController = TextEditingController();
  List<Disease> listDisease = [];
  File? _selectedImage;
  bool isReceiveResult = false;
  bool imgSelect = false;
  bool isLoading = false;
  bool isCheckedDis = false;
  bool isOpenedOtherDisease = false;
  bool showOtherText = false;
  String? resultDisName;
  String? selectedRadioOption;

  List<Prediction> predList = [];

  @override
  void initState() {
    _getAllDisease();
    super.initState();
    if(widget.selectedImage != null){
      _selectedImage = widget.selectedImage;
      _sendImageToApi();
    }
  }

  void _getAllDisease() async{
    final result = await DiseaseApi.getDiseases();
    listDisease = result ?? [];
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        isLoading = true;
        _sendImageToApi();
      });
    }
  }

  void _sendImageToApi() async{
    List<Prediction> preds = await DiseaseApi.uploadImage(_selectedImage!);
    setState(() {
      isLoading = false;
      isReceiveResult = true;
      predList = preds;
      resultDisName = predList.reduce((a, b) => a.probability > b.probability ? a : b).className;
      isCheckedDis = false;
    });
  }

  void _saveNewDisease(String? resultDisName) async{
    if(resultDisName == null){
      return;
    }

    final newDisease = DiseaseUploadRequest(diseaseName: resultDisName, imageBase64: await fileToBase64(_selectedImage!));

    bool result = await DiseaseApi.createNewDisease(newDisease);

    if(result){
      return showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(
            "Hastalık Oluşturma",
            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
          content: Text("Hastalık verisi başarıyla kaydedildi.", style: TextStyle(fontSize: 15),),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  isCheckedDis = true;
                });
                Navigator.of(context).pop();
              },
              child: const Text("Tamam"),
            ),
          ],
        ),
      );
    }

    ErrorManager.show(context: context, title: "Hastalık Oluşturma", message: "Hastalık verisi kaydedilirken problem oluştu.");

  }

  Future<String> fileToBase64(File file) async {
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result){
        if(!didPop){
          BaseNavigator.pushAndRemoveAll(context, MainMenuScreen(), "/mainMenuScreen");
        }
      },
      child: Scaffold(
        drawer: CustomDrawer(),
        appBar: AppBarWidget(),
        body: Stack(
          children: [
            Positioned.fill(
              child: isReceiveResult == false ?
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: _uploadArea(),
                ),
              ) :
              SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Column(
                  children: [
                    _uploadArea(),
                    _imageArea(),
                    _resultArea(),
                    _chartArea(),
                    if (!isCheckedDis) _showResultOption(),
                  ],
                ),
              ),
            ),

            if (isLoading)
              Positioned.fill(
                child: Container(
                  color: Color.fromRGBO(0, 0, 0, 0.4),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          strokeAlign: 6,
                          strokeWidth: 10,
                          color: Colors.red,
                        ),
                        SizedBox(height: 45),
                        Text(
                          "Lütfen Bekleyin...",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if(isOpenedOtherDisease)
              _otherDiseaseModal()
          ],
        ),
      ),
    );
  }


  Widget _uploadArea() {
    return Container(
      margin: EdgeInsets.only(bottom: 30),
      width: double.maxFinite,
      height: 180,
      decoration: BoxDecoration(
        border: DashedBorder.all(dashLength: 10, color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(10)
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Hastalık Resmi", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
          SizedBox(height: 20,),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            width: double.maxFinite,
            height: 70,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, style: BorderStyle.solid, width: 1.5),
              borderRadius: BorderRadius.circular(15)
            ),
            child: imgSelect == false ? Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      BaseNavigator.push(context, RealTimeCameraScreen(), "/realTimeCameraScreen");
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_enhance),
                        Text("Kamera")
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: (){
                      setState(() {
                        imgSelect = true;
                      });
                      Future.delayed(Duration(seconds: 5), () {
                        if (mounted) {
                          setState(() {
                            imgSelect = false;
                          });
                        }
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image),
                        Text("Resim")
                      ],
                    ),
                  ),
                )
              ],
            ) :
            _imageUpload(),
          )
        ],
      ),
    );
  }

  Row _imageUpload(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(child: Text(_selectedImage == null ? "Resim Dosyası" : _selectedImage!.path.split('/').last, textAlign: TextAlign.center,)),
        InkWell(
          onTap: _pickImage,
          child: Container(
            width: 150,
            height: double.maxFinite,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.only(topRight: Radius.circular(15), bottomRight: Radius.circular(15))
            ),
            child: Text("Dosya Seç"),
          ),
        )
      ],
    );
  }

  Widget _resultArea() {
    return Container(
      margin: EdgeInsets.only(bottom: 30),
      width: double.maxFinite,
      height: 110,
      decoration: BoxDecoration(
        color: Colors.grey[400],
        borderRadius: BorderRadius.circular(10)
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Sorgulama Sonucu", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
          SizedBox(height: 15,),
          Text(DiseaseTr.disTrList[resultDisName]!, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),)
        ],
      ),
    );
  }

  Widget _imageArea() {
    return Container(
      margin: EdgeInsets.only(bottom: 30),
      width: double.maxFinite,
      height: 350,
      decoration: BoxDecoration(
          color: Colors.grey[400],
          borderRadius: BorderRadius.circular(10)
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 20,),
          Text("Hastalık Resmi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
          SizedBox(height: 15,),
          Expanded(
            child: Image.file(
              _selectedImage!
            ),
          ),
          SizedBox(height: 10,)
        ],
      ),
    );
  }

  Widget _chartArea(){
    return Container(
      margin: EdgeInsets.only(bottom: 30),
      width: double.maxFinite,
      height: 400,
      decoration: BoxDecoration(
          color: Colors.grey[400],
          borderRadius: BorderRadius.circular(10)
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 10,),
          Text("Hastalık Oranları", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
          SizedBox(height: 20,),
          Expanded(
            child: PieChart(
                PieChartData(
                    sections: _pieChartArea(),
                    sectionsSpace: 2,
                    centerSpaceRadius: 50
                )
            ),
          ),
          SizedBox(height: 20),
          _buildLegend(),
        ],
      ),
    );
  }

  List<PieChartSectionData> _pieChartArea() {
    return List.generate(predList.length, (i){
      final item = predList[i];
      return PieChartSectionData(
        value: item.probability * 100,
        title: '${(item.probability * 100).toStringAsFixed(1)}%',
        color: _getColor(i),
        radius: 60,
        titleStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
      );
    });
  }

  Padding _buildLegend() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(predList.length, (i) {
          final item = predList[i];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 14,
                  height: 14,
                  margin: EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    color: _getColor(i),
                    shape: BoxShape.rectangle,
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Text(
                    DiseaseTr.disTrList[item.className]!,
                    style: TextStyle(fontSize: 14),
                    softWrap: true,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    )
    ;
  }

  Color _getColor(int index) {
    const colors = [
      Colors.brown,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal
    ];
    return colors[index % colors.length];
  }

  Widget _showResultOption() {
    return Container(
        width: double.maxFinite,
        height: 150,
        margin: EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
            color: Colors.grey[400],
            borderRadius: BorderRadius.circular(10)
        ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Teşhis doğru sonucu gösterdi mi?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
          SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: (){
                  setState(() {
                    isOpenedOtherDisease = true;
                  });
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.red),
                  padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 10, horizontal: 40)),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                    )
                  )
                ),
                child: Text("Hayır", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),),
              ),
              TextButton(
                onPressed: (){
                  _saveNewDisease(resultDisName);
                  _selectedImage = null;
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.green),
                  padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 10, horizontal: 40)),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                    )
                  )
                ),
                child: Text("Evet", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _otherDiseaseModal() {
    return Positioned.fill(
      child: Container(
        color: Color.fromRGBO(0, 0, 0, 0.4),
        padding: EdgeInsets.symmetric(vertical: 50, horizontal: 20),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(10),
            width: double.maxFinite,
            height: double.maxFinite,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                SizedBox(height: 10,),
                Text("Hastalık Bilgileri", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                SizedBox(height: 20,),
                Wrap(
                  spacing: 20,
                  runSpacing: 15,
                  alignment: WrapAlignment.center,
                  children: [
                    ...listDisease.map((option) {
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 4),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Radio(
                              value: option.diseaseName,
                              groupValue: selectedRadioOption,
                              onChanged: (value) {
                                setState(() {
                                  selectedRadioOption = value;
                                  showOtherText = false;
                                  _otherTextController.text = "";
                                });
                              },
                            ),
                            Text(
                              option.diseaseName,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      );
                    }).toList(),

                    /// "Diğer" seçeneği
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Radio<String>(
                            value: 'other',
                            groupValue: selectedRadioOption,
                            onChanged: (value) {
                              setState(() {
                                selectedRadioOption = value;
                                showOtherText = true;
                              });
                            },
                          ),
                          Text(
                            'Diğer',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 30,),

                if(showOtherText) TextField(
                  controller: _otherTextController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "Hastalık adını lütfen ingilizce giriniz.",
                    contentPadding: EdgeInsets.all(12),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                SizedBox(height: 40,),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: (){
                        setState(() {
                          isOpenedOtherDisease = false;
                          _otherTextController.text = "";
                          selectedRadioOption = "";
                          showOtherText = false;
                        });
                      },
                      style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(Colors.red),
                          padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 10, horizontal: 40)),
                          shape: WidgetStatePropertyAll(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)
                              )
                          )
                      ),
                      child: Text("Kapat", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),),
                    ),
                    TextButton(
                      onPressed: (){
                        if(selectedRadioOption == ""){
                          ErrorManager.show(context: context, title: "Hastalık Kayıt", message: "Geçerli bir hastalık seçiniz.");
                          return;
                        }
                        if(selectedRadioOption == "other" && _otherTextController.text.trim() == ""){
                          ErrorManager.show(context: context, title: "Hastalık Kayıt", message: "Geçerli bir hastalık giriniz.");
                          return;
                        }
                        if(selectedRadioOption == "other"){
                         _saveNewDisease(_otherTextController.text.trim());
                        }
                        else{
                          _saveNewDisease(selectedRadioOption);
                        }
                        setState(() {
                          isOpenedOtherDisease = false;
                          _otherTextController.text = "";
                          selectedRadioOption = "";
                          showOtherText = false;
                          isCheckedDis = true;
                          _selectedImage = null;
                        });
                      },
                      style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(Colors.green),
                          padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 10, horizontal: 40)),
                          shape: WidgetStatePropertyAll(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)
                              )
                          )
                      ),
                      child: Text("Kaydet", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }








}