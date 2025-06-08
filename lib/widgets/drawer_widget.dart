import 'package:dermainsight/managers/user_manager.dart';
import 'package:dermainsight/screens/login_screen.dart';
import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {

  const CustomDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Color(0xFF1e1e1e),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Menü",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Ad Soyad
              Text(
                "${(UserManager.activeUser!.UserType == "Doktor" ? "Dr. ${UserManager.activeUser!.Name}" : UserManager.activeUser!.Name)} ${UserManager.activeUser!.Surname}",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              // ID
              Text(
                "(ID: ${UserManager.activeUser!.Id})",
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                ),
              ),

              const SizedBox(height: 10),

              // ID
              Text(
                "[${UserManager.activeUser!.UserType}]",
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                ),
              ),

              Spacer(),

              // Çıkış Butonu
              ElevatedButton.icon(
                onPressed: (){
                  UserManager.activeUser = null;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                        (Route<dynamic> route) => false, // 🔁 tüm önceki sayfaları kapatır
                  );

                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: Icon(Icons.logout, color: Colors.white),
                label: Text(
                  "Çıkış",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
