import 'package:flutter/widgets.dart';

import '../features/home/services/category_socket_service.dart';
import '../features/store/services/product_socket_service.dart';

import 'outlet_state.dart';

class AppLifecycleHandler extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      /// ✅ categories always reconnect
      CategorySocketService.connect();

      /// ✅ reconnect products only if inside outlet
      if (OutletState.hasOutlet) {
        ProductSocketService.connect(
          OutletState.outletId!, // safe because hasOutlet true
        );
      }
    }
  }
}
