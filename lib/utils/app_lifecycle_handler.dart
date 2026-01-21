import 'package:flutter/widgets.dart';
import '../features/home/services/product_socket_service.dart';
import '../features/home/services/category_socket_service.dart';

class AppLifecycleHandler
    extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(
      AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ProductSocketService.connect();
      CategorySocketService.connect();
    }
  }
}
