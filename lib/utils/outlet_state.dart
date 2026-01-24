/// Holds currently selected outlet across the app
/// Works like a small global session

class OutletState {
  OutletState._();

  static String? _outletId;

  /* ================================================= */
  /* GETTERS                                           */
  /* ================================================= */

  static String? get outletId => _outletId;

  static bool get hasOutlet => _outletId != null;

  /* ================================================= */
  /* SETTER                                            */
  /* ================================================= */

  static void set(String id) {
    _outletId = id;
  }

  /* ================================================= */
  /* CLEAR (logout / change store)                      */
  /* ================================================= */

  static void clear() {
    _outletId = null;
  }
}
