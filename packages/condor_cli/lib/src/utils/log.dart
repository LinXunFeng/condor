/// Log messages to the console with colors
class Log {
  Log._();

  /// Print a message in blue
  static void info(String msg) {
    _log('\x1B[34m$msg\x1B[0m');
  }

  /// Print a message in green
  static void success(String msg) {
    _log('\x1B[32m$msg\x1B[0m');
  }

  /// Print a message in yellow
  static warning(String msg) {
    _log('\x1B[33m$msg\x1B[0m');
  }

  /// Print a message in red
  static error(String msg) {
    _log('\x1B[31m$msg\x1B[0m');
  }

  /// Print a message in red and exit
  static _log(String message) {
    print(message);
  }
}
