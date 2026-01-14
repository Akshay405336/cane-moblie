import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../models/product.model.dart';
import '../../../env.dart';

class ProductSocketService {
  ProductSocketService._();

  static IO.Socket? _socket;

  static final List<void Function(List<Product>)> _listeners = [];

  // 🔥 CACHE (CRITICAL)
  static List<Product> _cachedProducts = [];

  /* ================================================= */
  /* CONNECT                                           */
  /* ================================================= */

  static void connect() {
    if (_socket != null && _socket!.connected) return;

    _socket = IO.io(
      '${Env.baseUrl}/public/products',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(2000)
          .build(),
    );

    /* 🔥 LISTENERS FIRST */

    _socket!.on('products.updated', (data) {
      if (data == null || data['products'] == null) return;

      final List list = data['products'] as List;

      final products = list
          .map(
            (e) => Product.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList();

      // ✅ UPDATE CACHE
      _cachedProducts = products;

      // ✅ NOTIFY ALL LISTENERS
      for (final listener in _listeners) {
        listener(products);
      }
    });

    /* 🔍 DEBUG LOGS */

    _socket!.onConnect((_) {
      print('✅ Product socket connected');
    });

    _socket!.onDisconnect((_) {
      print('❌ Product socket disconnected');
    });

    _socket!.onError((err) {
      print('🔥 Product socket error: $err');
    });

    _socket!.onAny((event, data) {
      print('📡 PRODUCT $event => $data');
    });

    /* 🚀 CONNECT LAST */
    _socket!.connect();
  }

  /* ================================================= */
  /* SUBSCRIBE / UNSUBSCRIBE                           */
  /* ================================================= */

  static void subscribe(
    void Function(List<Product>) listener,
  ) {
    _listeners.add(listener);

    // 🔥 INSTANT REPLAY FOR LATE SUBSCRIBERS
    if (_cachedProducts.isNotEmpty) {
      listener(_cachedProducts);
    }
  }

  static void unsubscribe(
    void Function(List<Product>) listener,
  ) {
    _listeners.remove(listener);
  }

  /* ================================================= */
  /* EXPOSE CACHE                                      */
  /* ================================================= */

  static List<Product> get cachedProducts =>
      _cachedProducts;

  /* ================================================= */
  /* DISCONNECT                                       */
  /* ================================================= */

  static void disconnect() {
    _listeners.clear();
    _cachedProducts = [];
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}
