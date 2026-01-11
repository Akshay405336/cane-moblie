import 'package:flutter/material.dart';

class CartPage extends StatelessWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Welcome to Cart 🛒',
        style: TextStyle(fontSize: 22),
      ),
    );
  }
}
