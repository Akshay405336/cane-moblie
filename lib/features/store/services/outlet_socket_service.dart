import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../../env.dart';
import '../models/outlet.model.dart';

class OutletSocketService {
  OutletSocketService._();

  static IO.Socket? _socket;

  static final List<void Function(List<Outlet>)> _listeners = [];

  static List<Outlet> _cachedOutlets = [];

  /* ================================================= */
  /* CONNECT                                           */
  /* ================================================= */

  static void connect({
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

      if (data == null || data['outlets'] == null) return;

      final List list = data['outlets'];

      final outlets = list
          .map((e) => Outlet.fromJson(
                Map<String, dynamic>.from(e),
              ))
          .toList();

      _cachedOutlets = outlets;

      debugPrint('📦 SOCKET → parsed outlets (${outlets.length})');

      for (final l in _listeners) {
        l(outlets);
      }
    });

    /* ================= DEBUG ================= */

    _socket!.onConnect((_) {
      debugPrint('✅ Outlet socket connected');
    });

    _socket!.onDisconnect((_) {
      debugPrint('❌ Outlet socket disconnected');
    });

    _socket!.onError((e) {
      debugPrint('❌ Outlet socket error => $e');
    });

    _socket!.onConnectError((e) {
      debugPrint('❌ Outlet socket connect error => $e');
    });

    _socket!.onReconnect((_) {
      debugPrint('🔁 Outlet socket reconnected');
    });

    _socket!.onAny((event, data) {
      debugPrint('📡 SOCKET EVENT → $event => $data');
    });

    _socket!.connect();
  }

  /* ================================================= */
  /* SUBSCRIBE                                          */
  /* ================================================= */

  static void subscribe(
    void Function(List<Outlet>) listener,
  ) {
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
    }

    /// instantly send cached data
    if (_cachedOutlets.isNotEmpty) {
      listener(_cachedOutlets);
    }
  }

  static void unsubscribe(
    void Function(List<Outlet>) listener,
  ) {
    _listeners.remove(listener);
  }

  /* ================================================= */
  /* CACHE                                             */
  /* ================================================= */

  static List<Outlet> get cachedOutlets => _cachedOutlets;

  /* ================================================= */
  /* DISCONNECT                                        */
  /* ================================================= */

  static void disconnect() {
    debugPrint('🔌 Outlet socket disconnect');

    // ❌ DO NOT clear listeners
    // listeners belong to UI lifecycle

    _cachedOutlets = [];

    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}