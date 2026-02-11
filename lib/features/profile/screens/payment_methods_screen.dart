import 'package:flutter/material.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: const Text('Payment Methods', 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoCard(),
          const SizedBox(height: 24),
          const Text("Available Methods", 
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 12),
          
          // 💳 Online Payments Tile
          _PaymentMethodTile(
            icon: Icons.public,
            title: "Online Payments",
            subtitle: "Cards, Netbanking & Wallets",
            color: Colors.orange,
          ),
          
          const SizedBox(height: 12),

          // 📱 UPI Tile
          _PaymentMethodTile(
            icon: Icons.account_balance_wallet_outlined,
            title: "UPI",
            subtitle: "Google Pay, PhonePe, Paytm & More",
            color: Colors.deepPurple,
          ),
          
          const SizedBox(height: 24),
          _buildNote(),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        children: [
          Icon(Icons.security, color: Colors.blue.shade700, size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Payments are handled securely via Razorpay. Your data is always encrypted.",
              style: TextStyle(fontSize: 12, color: Colors.blue, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNote() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        "Note: You can select your preferred payment method during the checkout process.",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// REUSABLE PAYMENT METHOD TILE
// ---------------------------------------------------------------------------

class _PaymentMethodTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _PaymentMethodTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle_outline, color: Colors.green.shade300, size: 20),
        ],
      ),
    );
  }
}