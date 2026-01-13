import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../models/category.model.dart';
import '../../../env.dart';

class CategorySocketService {
  CategorySocketService._();

  static IO.Socket? _socket;

  static final List<void Function(List<Category>)> _listeners = [];

  // 🔥 CACHE (CRITICAL FIX)
  static List<Category> _cachedCategories = [];

  /* ================================================= */
  /* CONNECT                                           */
  /* ================================================= */

  static void connect() {
    if (_socket != null && _socket!.connected) return;

    _socket = IO.io(
      '${Env.baseUrl}/public/categories',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(2000)
          .build(),
    );

    /* 🔥 LISTENERS FIRST */

    _socket!.on('categories.updated', (data) {
      if (data == null || data['categories'] == null) return;

      final List list = data['categories'] as List;

      final categories = list
          .map(
            (e) => Category.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList();

      // ✅ UPDATE CACHE
      _cachedCategories = categories;

      // ✅ NOTIFY ALL LISTENERS
      for (final listener in _listeners) {
        listener(categories);
      }
    });

    /* 🔍 DEBUG LOGS */

    _socket!.onConnect((_) {
      print('✅ Category socket connected');
    });

    _socket!.onDisconnect((_) {
      print('❌ Category socket disconnected');
    });

    _socket!.onError((err) {
      print('🔥 Socket error: $err');
    });

    _socket!.onAny((event, data) {
      print('📡 $event => $data');
    });

    /* 🚀 CONNECT LAST */
    _socket!.connect();
  }

  /* ================================================= */
  /* SUBSCRIBE / UNSUBSCRIBE                           */
  /* ================================================= */

  static void subscribe(
    void Function(List<Category>) listener,
  ) {
    _listeners.add(listener);

    // 🔥 INSTANT REPLAY FOR LATE SUBSCRIBERS
    if (_cachedCategories.isNotEmpty) {
      listener(_cachedCategories);
    }
  }

  static void unsubscribe(
    void Function(List<Category>) listener,
  ) {
    _listeners.remove(listener);
  }

  /* ================================================= */
  /* EXPOSE CACHE                                      */
  /* ================================================= */

  static List<Category> get cachedCategories =>
      _cachedCategories;

  /* ================================================= */
  /* DISCONNECT                                       */
  /* ================================================= */

  static void disconnect() {
    _listeners.clear();
    _cachedCategories = [];
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}
