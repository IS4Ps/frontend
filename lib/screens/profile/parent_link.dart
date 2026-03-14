import 'package:flutter/material.dart';

class ParentLink extends StatelessWidget {
  const ParentLink({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 300,
        height: 200,
        child: Center(
          child: Text('모달 테스트'),
        ),
      ),
    );
  }
}

