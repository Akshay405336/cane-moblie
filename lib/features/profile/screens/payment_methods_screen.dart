import 'package:flutter/material.dart';

// --- STYLING CONSTANTS ---
const kPrimaryColor = Color(0xFF2E7D32);
const kBgColor = Color(0xFFF8FAFB);
const kAccentBlue = Color(0xFF0D47A1);

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      appBar: AppBar(
        title: const Text(
          'Payment Methods',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.w800,
            fontSize: 19,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        shape: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        physics: const BouncingScrollPhysics(),
        children: [
          // 🛡️ Enhanced Security Header
          _buildInfoCard(),
          
          const SizedBox(height: 32),
          
          Row(
            children: [
              Text(
                "AVAILABLE METHODS",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey.shade500,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              const Icon(Icons.lock_outline_rounded, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text("Secure", style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            ],
          ),
          const SizedBox(height: 16),
          
          // 💳 Online Payments Tile
          _PaymentMethodTile(
            icon: Icons.credit_card_rounded,
            title: "Online Payments",
            subtitle: "Debit/Credit Cards, Netbanking",
            color: Colors.orange.shade700,
            trailingIcon: Icons.arrow_forward_ios_rounded,
          ),
          
          const SizedBox(height: 16),

          // 📱 UPI Tile
          _PaymentMethodTile(
            icon: Icons.phonelink_ring_rounded,
            title: "UPI Transfer",
            subtitle: "GPay, PhonePe, Paytm, Any UPI ID",
            color: Colors.deepPurple.shade600,
            trailingIcon: Icons.arrow_forward_ios_rounded,
          ),

          const SizedBox(height: 16),
          
          const SizedBox(height: 40),
          _buildNote(),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kAccentBlue.withOpacity(0.05), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kAccentBlue.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kAccentBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.verified_user_rounded, color: kAccentBlue, size: 24),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Secure Checkout",
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: kAccentBlue),
                ),
                SizedBox(height: 4),
                Text(
                  "Payments are handled securely via Razorpay. Your sensitive data is encrypted with bank-grade security.",
                  style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: Colors.grey),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "You will be redirected to our secure payment gateway to complete your transaction.",
              style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final IconData trailingIcon;

  const _PaymentMethodTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {}, // Logic for selection
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800, 
                          fontSize: 16, 
                          color: Color(0xFF1A1A1A)
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12, 
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(trailingIcon, color: Colors.grey.shade300, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}