import 'package:flutter/material.dart';
import '../../home/theme/home_colors.dart';
import '../../orders/models/order.model.dart';

class OrderSuccessScreen extends StatelessWidget {
  final Order order;
  const OrderSuccessScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: HomeColors.primaryGreen, size: 80),
              const SizedBox(height: 20),
              const Text("Order Placed!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text("Order ID: #${order.id.substring(0, 8).toUpperCase()}"),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Continue Shopping"),
              )
            ],
          ),
        ),
      ),
    );
  }
}