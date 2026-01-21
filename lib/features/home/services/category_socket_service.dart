import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../models/category.model.dart';
import '../../../env.dart';

class CategorySocketService {
  CategorySocketService._();

  static IO.Socket? _socket;

  static final List<void Function(List<Category>)> _listeners = [];

  // 🔥 CACHE (SOURCE OF TRUTH)
  static List<Category> _cachedCategories = [];

  /* ================================================= */
  /* CONNECT                                           */
  /* ================================================= */

  static void connect() {
    if (_socket != null && _socket!.connected) {
      print('ℹ️ CATEGORY SOCKET already connected');
      return;
    }

    print('🚀 CONNECTING category socket...');

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

    /* ================================================= */
    /* 🔥 SOCKET EVENTS                                  */
    /* ================================================= */

    _socket!.onConnect((_) {
      print('✅ CATEGORY SOCKET CONNECTED');
    });

    _socket!.onDisconnect((_) {
      print('❌ CATEGORY SOCKET DISCONNECTED');
    });

    _socket!.onError((err) {
      print('🔥 CATEGORY SOCKET ERROR: $err');
    });

    _socket!.onAny((event, data) {
      print('📡 CATEGORY SOCKET EVENT: $event');
    });

    /* ================================================= */
    /* 🔥 DATA EVENT                                     */
    /* ================================================= */

    _socket!.on('categories.updated', (data) {
      print('🟢 FLUTTER RECEIVED categories.updated');
      print('📦 RAW DATA => $data');

      if (data == null || data['categories'] == null) {
        print('⚠️ categories.updated payload invalid');
        return;
      }

      final List list = data['categories'] as List;

      final categories = list
          .map(
            (e) => Category.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList();

      print(
        '🎯 PARSED ${categories.length} categories',
      );

      // ✅ UPDATE CACHE
      _cachedCategories = categories;

      // ✅ NOTIFY ALL LISTENERS
      for (final listener in _listeners) {
        listener(categories);
      }
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
    if (!_listeners.contains(listener)) {
      print('➕ CATEGORY SUBSCRIBER ADDED');
      _listeners.add(listener);
    }

    // 🔥 INSTANT REPLAY FOR LATE SUBSCRIBERS
    if (_cachedCategories.isNotEmpty) {
      print(
        '⏪ REPLAYING ${_cachedCategories.length} cached categories',
      );
      listener(_cachedCategories);
    }
  }

  static void unsubscribe(
    void Function(List<Category>) listener,
  ) {
    print('➖ CATEGORY SUBSCRIBER REMOVED');
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
    print('🧹 CATEGORY SOCKET DISCONNECT');
    _listeners.clear();
    _cachedCategories = [];
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}
