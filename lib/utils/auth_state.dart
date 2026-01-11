/// lib/utils/auth_state.dart
class AuthState {
  AuthState._(); // private constructor

  /* ================================================= */
  /* AUTH STATUS                                      */
  /* ================================================= */

  static bool _isAuthenticated = false;
  static bool _initialized = false;

  /* ================================================= */
  /* GETTERS                                          */
  /* ================================================= */

  /// true = logged in
  /// false = guest
  static bool get isAuthenticated => _isAuthenticated;

  /// true = splash auth check completed
  static bool get isInitialized => _initialized;

  /* ================================================= */
  /* MUTATORS                                         */
  /* ================================================= */

  /// Call when user is logged in (OTP success / session valid)
  static void setAuthenticated(bool value) {
    _isAuthenticated = value;
    _initialized = true;
  }

  /// Call when user is a guest (skip login / session invalid)
  static void setGuest() {
    _isAuthenticated = false;
    _initialized = true;
  }

  /// Call only on hard logout
  static void reset() {
    _isAuthenticated = false;
    _initialized = false;
  }
}
