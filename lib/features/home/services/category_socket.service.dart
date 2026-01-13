import 'package:socket_io_client/socket_io_client.dart' as IO;

class CategorySocketService {
  CategorySocketService._();

  static IO.Socket? _socket;

  static void connect({
    required Function() onUpdate,
  }) {
    if (_socket != null && _socket!.connected) return;

    _socket = IO.io(
      '/public/categories',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    _socket!.connect();

    _socket!.onAny((_, __) {
      onUpdate();
    });
  }

  static void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}
