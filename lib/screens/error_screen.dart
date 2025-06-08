import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget{
  final int statusCode;
  final String message;
  final String requestedPath;
  final String exceptionDetails;

  const ErrorScreen({
    super.key,
    this.statusCode = 500,
    this.message = "Sunucuya erişirken hata oluştu.",
    this.requestedPath = "Bilinmeyen Sayfa",
    this.exceptionDetails = "FastAPI sunucusuna erişilemedi.",
  });


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        padding: EdgeInsets.only(top: 70, bottom: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Dermainsight", style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(message, style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold)),
                    SizedBox(height: 20,),
                    Text("Hata Kodu: $statusCode", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 20,),
                    Text(requestedPath, style: TextStyle(color: Colors.white, fontSize: 17.5, fontWeight: FontWeight.bold)),
                    SizedBox(height: 20,),
                    Text(exceptionDetails, style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

}