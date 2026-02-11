import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../../env.dart';
import '../models/outlet.model.dart';

class OutletSocketService {
  /* ================================================= */
  /* ⭐ SINGLETON INSTANCE                              */
  /* ================================================= */
  
  // Private constructor
  OutletSocketService._();
  
  // Static final instance for global access
  static final OutletSocketService instance = OutletSocketService._();

  IO.Socket? _socket;
  final List<void Function(List<Outlet>)> _listeners = [];
  List<Outlet> _cachedOutlets = [];

  // Getter to safely access cached outlets from CartPage or other controllers
  List<Outlet> get cachedOutlets => List.unmodifiable(_cachedOutlets);

  /* ================================================= */
  /* CONNECT                                           */
  /* ================================================= */

  void connect({
    required double lat,
    required double lng,
  }) {
    if (_socket != null && _socket!.connected) {
      debugPrint('ℹ️ Outlet socket already connected');
      return;
    }

    debugPrint(
      '📡 SOCKET → Connecting outlets with lat=$lat, lng=$lng',
    );

    _socket = IO.io(
      '${Env.baseUrl}/public/outlets',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({
            'lat': lat,
            'lng': lng,
          })
          .disableAutoConnect()
          .enableReconnection()
          .build(),
    );

    /* ================================================= */
    /* LISTENERS                                         */
    /* ================================================= */

    _socket!.on('outlets.updated', (data) {
      debugPrint('📡 RAW EVENT → outlets.updated => $data');

      if (data == null || data['outlets'] == null) {
        debugPrint('⚠️ outlets.updated → empty payload');
        return;
      }

      try {
        final List list = data['outlets'];

        final outlets = list.map((e) {
          final wrapper = Map<String, dynamic>.from(e);

          final outletJson =
              Map<String, dynamic>.from(wrapper['outlet']);

          final distanceKm =
              (wrapper['distanceKm'] as num?)?.toDouble();

          // 🔥 FIX: inject distanceKm into outlet json
          outletJson['distanceKm'] = distanceKm;

          return Outlet.fromJson(outletJson);
        }).toList();

        _cachedOutlets = outlets;

        debugPrint(
          '📦 SOCKET → parsed outlets (${outlets.length})',
        );

        for (final l in _listeners) {
          l(outlets);
        }
      } catch (e, s) {
        debugPrint('❌ Socket parse crash → $e');
        debugPrintStack(stackTrace: s);
      }
    });

    _socket!.onConnect((_) {
      debugPrint('✅ Outlet socket connected');
    });

    _socket!.onConnectError((err) => debugPrint('❌ Socket Connect Error: $err'));

    _socket!.onDisconnect((_) {
      debugPrint('❌ Outlet socket disconnected');
    });

    _socket!.connect();
  }

  /* ================================================= */
  /* SUBSCRIBE                                         */
  /* ================================================= */

  void subscribe(
    void Function(List<Outlet>) listener,
  ) {
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
    }

    if (_cachedOutlets.isNotEmpty) {
      listener(_cachedOutlets);
    }
  }

  void unsubscribe(
    void Function(List<Outlet>) listener,
  ) {
    _listeners.remove(listener);
  }

  /* ================================================= */
  /* DISCONNECT                                        */
  /* ================================================= */

  void disconnect() {
    debugPrint('🔌 Outlet socket disconnect');

    _cachedOutlets = [];
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}