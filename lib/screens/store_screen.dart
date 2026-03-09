import 'package:flutter/material.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  int _selectedIndex = 0; // 선택된 탭 인덱스
  final List<String> _categories = ["상점", "장비", "보상"];

  Set<int> _equippedIndexes = {};
  int? _activeIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "상점",
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        backgroundColor: const Color(0xFF1586E2),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: List.generate(_categories.length, (index) {
                return Padding(
                  padding: EdgeInsets.only(right: index < _categories.length - 1 ? 10 : 0),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedIndex = index), // ← 탭 클릭 시 변경
                    child: _categoryButton(_categories[index], _selectedIndex == index),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: _buildContent(), // ← 탭에 따라 다른 화면
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildShopGrid();
      case 1:
        return _buildEquipmentGrid(); // 장비 화면
      case 2:
        return _buildRewardGrid();    // 보상 화면
      default:
        return _buildShopGrid();
    }
  }

  Widget _buildShopGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 8,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 30,
        mainAxisSpacing: 30,
        childAspectRatio: 0.7,
      ),
      itemBuilder: (context, index) => _itemCard("500gold"),
    );
  }

  Widget _buildEquipmentGrid() {
    return GestureDetector(
      onTap: () => setState(() => _activeIndex = null), // ← 배경 클릭 시 장착 해제 버튼만 숨김
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 30,
          mainAxisSpacing: 30,
          childAspectRatio: 0.7,
        ),
        itemBuilder: (context, index) => _equipmentCard(
          ["용사의 검", "용사의 투구", "용사의 신발"][index],
          _equippedIndexes.contains(index),
          _activeIndex == index,
              () => setState(() {
            _equippedIndexes.add(index);
            _activeIndex = index;
          }),
              () => setState(() {
            _equippedIndexes.remove(index);
            _activeIndex = null;
          }),
        ),
      ),
    );
  }

  Widget _equipmentCard(String label, bool isEquipped, bool isActive, VoidCallback onTap, VoidCallback onUnequip) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: isActive
              ? Border.all(color: const Color(0xFF1586E2), width: 2)
              : null,
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      width: 75,
                      height: 75,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD9D9D9),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  if (isEquipped)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          "장착 중",
                          style: TextStyle(fontSize: 11, color: Colors.black87, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (isActive)
              GestureDetector(
                onTap: onUnequip,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    "장착 해제",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5, // 보상 아이템 수
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 30,
        mainAxisSpacing: 30,
        childAspectRatio: 0.7,
      ),
      itemBuilder: (context, index) => _itemCard("보상 ${index + 1}"),
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

Widget _itemCard(String label) {
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
              width: 75,
              height: 75,
              decoration: const BoxDecoration(
                color: Color(0xFFD9D9D9),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    ),
  );
}