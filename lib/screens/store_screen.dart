import 'package:flutter/material.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text(
          "상점",
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false, // 왼쪽 정렬
        backgroundColor: const Color(0xFF1586E2),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _categoryButton("상점", true),
                const SizedBox(width: 10),
                _categoryButton("장비", false),
                const SizedBox(width: 10),
                _categoryButton("보상", false),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 8,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 30,
                mainAxisSpacing: 30,
                childAspectRatio: 0.7,
              ),
              itemBuilder: (context, index) {
                return _itemCard();
              },
            ),
          ),
        ],
      ),
    );
  }
}

Widget _categoryButton(String text, bool selected) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 5),
    decoration: BoxDecoration(
      color: selected
          ? const Color(0xFF1586E2).withOpacity(0.4)
          : Colors.grey[300],
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold),
    ),
  );
}

Widget _itemCard() {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 4,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFD9D9D9),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Text(
            "500gold",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14),
          ),
        ),
      ],
    ),
  );
}