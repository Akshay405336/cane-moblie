import 'package:flutter/material.dart';

class CheckoutBillSummary extends StatelessWidget {
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double grandTotal;

  const CheckoutBillSummary({
    super.key,
    required this.subtotal,
    required this.deliveryFee,
    required this.discount,
    required this.grandTotal,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12, left: 4),
          child: Text(
            "Bill Details",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black87),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _BillRow("Item Total", subtotal),
              _BillRow("Delivery Fee", deliveryFee),
              if (discount > 0)
                _BillRow("Discount", -discount, isGreen: true),
              
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Divider(height: 1, color: Colors.grey[200]),
              ),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("To Pay",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                  Text("₹${grandTotal.toStringAsFixed(0)}",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black87)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BillRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool isGreen;
  
  const _BillRow(this.label, this.amount, {this.isGreen = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600])),
          Text(
            "${amount < 0 ? '-' : ''}₹${amount.abs().toStringAsFixed(0)}",
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isGreen ? Colors.green[700] : Colors.black87),
          ),
        ],
      ),
    );
  }
}