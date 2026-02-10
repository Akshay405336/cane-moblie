import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../env.dart';
import '../../orders/models/order.model.dart';

class OrderSocketService {
  OrderSocketService._();

  static IO.Socket? _socket;
  static void Function(Order)? _onOrderUpdated;

  /* ================================================= */
  /* CONNECT & LISTEN                                  */
  /* ================================================= */
  static void connectAndListen(String orderId, {required void Function(Order) onUpdate}) {
    if (_socket != null) disconnect();

    _onOrderUpdated = onUpdate;

    debugPrint('📡 ORDER SOCKET → Connecting for Order: $orderId');

    // Assuming your backend has a specific namespace for orders
    _socket = IO.io(
      '${Env.baseUrl}/orders', 
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setQuery({'orderId': orderId}) // Pass orderId so backend knows what to send
          .disableAutoConnect()
          .enableReconnection()
          .build(),
    );

    _socket!.onConnect((_) => debugPrint('✅ Order Socket Connected'));

    // This event should be emitted by your backend when payment is verified
    _socket!.on('order.status.changed', (data) {
      debugPrint('⚡ SOCKET EVENT → order.status.changed: $data');
      try {
        final updatedOrder = Order.fromJson(data);
        if (_onOrderUpdated != null) {
          _onOrderUpdated!(updatedOrder);
        }
      } catch (e) {
        debugPrint('❌ Order Socket Parse Error: $e');
      }
    });

    _socket!.onDisconnect((_) => debugPrint('❌ Order Socket Disconnected'));
    
    _socket!.connect();
  }

  /* ================================================= */
  /* DISCONNECT                                        */
  /* ================================================= */
  static void disconnect() {
    debugPrint('🔌 Closing Order Socket');
    _onOrderUpdated = null;
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}