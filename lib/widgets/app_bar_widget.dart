import 'package:flutter/material.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  const AppBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: const Text(
        "Dermainsight",
        style: TextStyle(fontSize: 23, fontWeight: FontWeight.w600),
      ),
      backgroundColor: const Color(0xFFC8C7C7),
      leading: Builder( // 🔁 doğru context için gerekli
        builder: (context) => Container(
          margin: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: const Color(0xFF8B0000),
          ),
          child: IconButton(
            onPressed: () {
              Scaffold.of(context).openDrawer(); // ✅ drawer açılır
            },
            icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 27),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
